const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3001;

// Middleware
app.use(cors());
app.use(bodyParser.json());

// CDS Hooks Discovery Endpoint
app.get('/cds-services', (req, res) => {
  res.json({
    services: [
      {
        hook: 'order-sign',
        id: 'medication-order-sign-advisor',
        title: 'Medication Order Sign Advisor',
        description: 'Provides recommendations when signing medication orders',
        prefetch: {
          patient: 'Patient/{{context.patientId}}',
          medications: 'MedicationRequest?patient={{context.patientId}}'
        }
      },
      {
        hook: 'order-sign',
        id: 'order-sign-contraindication-check',
        title: 'Contraindication Check',
        description: 'Checks for contraindications when signing orders',
        prefetch: {
          patient: 'Patient/{{context.patientId}}'
        }
      }
    ]
  });
});

// CDS Service: Medication Order Sign Advisor
app.post('/cds-services/medication-order-sign-advisor', (req, res) => {
  const { context, prefetch, hook, hookInstance, fhirServer } = req.body;
  
  console.log('Received order-sign request:', JSON.stringify(req.body, null, 2));

  const cards = [];

  // Example: Check if there's a draft order (medication or service)
  if (context && context.draftOrders && context.draftOrders.entry) {
    // Support MedicationRequest, MedicationOrder, and ServiceRequest resource types
    const orders = context.draftOrders.entry.filter(
      entry => entry.resource && (
        entry.resource.resourceType === 'MedicationRequest' ||
        entry.resource.resourceType === 'MedicationOrder' ||
        entry.resource.resourceType === 'ServiceRequest'
      )
    );

    if (orders.length > 0) {
      const patientId = context.patientId || 'unknown-patient';
      const firstOrder = orders[0].resource;
      const orderType = firstOrder.resourceType;
      
      // Extract order code and display
      let orderCode = 'N/A';
      let orderDisplay = 'N/A';
      
      if (orderType === 'ServiceRequest' && firstOrder.code) {
        const coding = firstOrder.code.coding?.[0];
        if (coding) {
          orderCode = coding.code;
          orderDisplay = coding.display || orderCode;
        }
      } else if ((orderType === 'MedicationRequest' || orderType === 'MedicationOrder') && firstOrder.medicationCodeableConcept) {
        const coding = firstOrder.medicationCodeableConcept.coding?.[0];
        if (coding) {
          orderCode = coding.code;
          orderDisplay = coding.display || orderCode;
        }
      }
      
      // Add CRD Coverage Requirements Card with extensions
      const isServiceRequest = orderType === 'ServiceRequest';
      
      cards.push({
        uuid: 'crd-coverage-001',
        summary: 'Prior Authorization Required',
        detail: isServiceRequest 
          ? `This service (${orderDisplay}) requires prior authorization. Coverage is conditional pending authorization.`
          : 'This medication requires prior authorization. Coverage is conditional pending authorization.',
        source: {
          label: 'Mock Payer CDS Service',
          url: 'http://localhost:3001',
          icon: 'https://example.com/img/icon-100px.png'
        },
        indicator: 'warning',
        extension: {
          'davinci-crd.coverage-information': {
            coverage: {
              reference: 'Coverage/example-coverage-123'
            },
            covered: 'conditional',
            'pa-needed': 'auth-needed',
            'doc-needed': 'both',
            'doc-purpose': ['withpa', 'withclaim'],
            'info-needed': ['performer', 'location'],
            billingCode: [
              {
                system: 'http://www.ama-assn.org/go/cpt',
                code: 'J1234',
                display: 'Medication Administration Code'
              }
            ],
            reason: [
              {
                coding: [
                  {
                    system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                    code: 'detail-code',
                    display: 'Requires detailed review'
                  }
                ]
              }
            ],
            detail: [
              {
                code: {
                  coding: [
                    {
                      system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                      code: 'allowed-quantity',
                      display: 'Allowed Quantity'
                    }
                  ]
                },
                valueQuantity: {
                  value: 30,
                  unit: 'tablets',
                  system: 'http://unitsofmeasure.org',
                  code: '{tablets}'
                }
              },
              {
                code: {
                  coding: [
                    {
                      system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                      code: 'allowed-period',
                      display: 'Allowed Period'
                    }
                  ]
                },
                valuePeriod: {
                  start: new Date().toISOString().split('T')[0],
                  end: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000).toISOString().split('T')[0]
                }
              },
              {
                code: {
                  coding: [
                    {
                      system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                      code: 'in-network-copay',
                      display: 'In-Network Copay'
                    }
                  ]
                },
                valueString: '$25.00'
              },
              {
                code: {
                  coding: [
                    {
                      system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                      code: 'auth-out-network-only',
                      display: 'Authorization Required for Out-of-Network Only'
                    }
                  ]
                },
                valueBoolean: true
              }
            ],
            qualification: 'Prior authorization required for this medication. Please submit clinical documentation including diagnosis, previous treatment history, and medical necessity. Expected review time: 2-3 business days.'
          }
        },
        suggestions: [
          {
            label: 'Start Prior Authorization Process',
            uuid: 'suggestion-pa-001',
            actions: [
              {
                type: 'create',
                description: 'Initiate prior authorization request',
                resource: {
                  resourceType: 'Task',
                  status: 'draft',
                  intent: 'proposal',
                  code: {
                    coding: [
                      {
                        system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                        code: 'prior-auth',
                        display: 'Prior Authorization'
                      }
                    ]
                  },
                  description: 'Prior authorization required for medication',
                  for: {
                    reference: `Patient/${patientId}`
                  }
                }
              }
            ]
          }
        ],
        links: [
          {
            label: 'Submit Prior Authorization',
            url: 'https://example-payer.com/prior-auth',
            type: 'absolute'
          },
          {
            label: 'View Coverage Details',
            url: 'https://example-payer.com/coverage/example-coverage-123',
            type: 'absolute'
          }
        ]
      });

      // Add an informational card for covered orders
      cards.push({
        uuid: 'order-sign-info-001',
        summary: isServiceRequest ? 'Service Coverage Information' : 'Medication Coverage Information',
        detail: isServiceRequest
          ? `You are about to sign ${orders.length} service order(s). Coverage verification completed for ${orderDisplay}.`
          : `You are about to sign ${orders.length} medication order(s). Coverage verification completed.`,
        source: {
          label: 'Mock Payer CDS Service',
          url: 'http://localhost:3001'
        },
        indicator: 'info',
        extension: {
          'davinci-crd.coverage-information': {
            coverage: {
              reference: 'Coverage/example-coverage-123'
            },
            covered: 'covered',
            'pa-needed': 'no-auth',
            'doc-needed': 'clinical',
            'doc-purpose': ['retain-doc'],
            'info-needed': [],
            reason: [
              {
                coding: [
                  {
                    system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                    code: 'gold-card',
                    display: 'Gold Card'
                  }
                ]
              }
            ],
            detail: [
              {
                code: {
                  coding: [
                    {
                      system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                      code: 'in-network-copay',
                      display: 'In-Network Copay'
                    }
                  ]
                },
                valueString: '$10.00'
              }
            ]
          }
        }
      });

      // Add a warning card for potential contraindications
      const medication = medicationOrders[0].resource;
      if (medication.medicationCodeableConcept || medication.medicationReference) {
        cards.push({
          uuid: 'medication-sign-warning-001',
          summary: 'Documentation Required',
          detail: 'This medication requires clinical documentation for claims processing.',
          source: {
            label: 'Mock Payer CDS Service',
            url: 'http://localhost:3001'
          },
          indicator: 'warning',
          extension: {
            'davinci-crd.coverage-information': {
              coverage: {
                reference: 'Coverage/example-coverage-123'
              },
              covered: 'covered',
              'pa-needed': 'no-auth',
              'doc-needed': 'clinical',
              'doc-purpose': ['withclaim', 'retain-doc'],
              'info-needed': ['timeframe'],
              detail: [
                {
                  code: {
                    coding: [
                      {
                        system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                        code: 'concurrent-review',
                        display: 'Concurrent Review Required'
                      }
                    ]
                  },
                  valueBoolean: true
                },
                {
                  code: {
                    coding: [
                      {
                        system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                        code: 'appropriate-use-needed',
                        display: 'Appropriate Use Criteria Required'
                      }
                    ]
                  },
                  valueBoolean: true
                }
              ],
              qualification: 'Clinical documentation must be submitted with claim. Include diagnosis codes, treatment plan, and expected duration of therapy.'
            }
          },
          suggestions: [
            {
              label: 'Attach Clinical Documentation',
              uuid: 'suggestion-doc-001',
              actions: [
                {
                  type: 'create',
                  description: 'Create documentation task',
                  resource: {
                    resourceType: 'Task',
                    status: 'draft',
                    intent: 'proposal',
                    code: {
                      coding: [
                        {
                          system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                          code: 'clinical-doc',
                          display: 'Clinical Documentation Required'
                        }
                      ]
                    },
                    description: 'Attach clinical documentation for claim',
                    for: {
                      reference: `Patient/${context.patientId}`
                    }
                  }
                }
              ]
            }
          ],
          links: [
            {
              label: 'Documentation Guidelines',
              url: 'https://example-payer.com/documentation-requirements',
              type: 'absolute'
            }
          ]
        });
      }
    }
  }

  res.json({
    cards: cards
  });
});

// CDS Service: Contraindication Check
app.post('/cds-services/order-sign-contraindication-check', (req, res) => {
  const { context } = req.body;
  
  console.log('Received contraindication check request:', JSON.stringify(req.body, null, 2));

  const cards = [];

  // Example contraindication check with CRD coverage information
  if (context && context.draftOrders) {
    cards.push({
      uuid: 'contraindication-check-001',
      summary: 'No Contraindications - Coverage Verified',
      detail: 'No known contraindications were found for this order. Coverage is confirmed with no prior authorization required.',
      source: {
        label: 'Mock Payer CDS Service',
        url: 'http://localhost:3001'
      },
      indicator: 'info',
      extension: {
        'davinci-crd.coverage-information': {
          coverage: {
            reference: 'Coverage/example-coverage-123'
          },
          covered: 'covered',
          'pa-needed': 'no-auth',
          'doc-needed': 'admin',
          'doc-purpose': ['retain-doc'],
          'info-needed': [],
          billingCode: [
            {
              system: 'http://www.ama-assn.org/go/cpt',
              code: '99213',
              display: 'Office Visit - Established Patient'
            }
          ],
          reason: [
            {
              coding: [
                {
                  system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                  code: 'gold-card',
                  display: 'Gold Card - Pre-approved'
                }
              ]
            }
          ],
          detail: [
            {
              code: {
                coding: [
                  {
                    system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                    code: 'allowed-quantity',
                    display: 'Allowed Quantity'
                  }
                ]
              },
              valueQuantity: {
                value: 90,
                unit: 'days',
                system: 'http://unitsofmeasure.org',
                code: 'd'
              }
            },
            {
              code: {
                coding: [
                  {
                    system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                    code: 'in-network-copay',
                    display: 'In-Network Copay'
                  }
                ]
              },
              valueString: '$0.00'
            },
            {
              code: {
                coding: [
                  {
                    system: 'http://hl7.org/fhir/us/davinci-crd/CodeSystem/temp',
                    code: 'out-network-copay',
                    display: 'Out-of-Network Copay'
                  }
                ]
              },
              valueString: '$50.00'
            }
          ],
          qualification: 'This service is fully covered under your current plan. Standard administrative documentation required for claim submission.'
        }
      }
    });
  }

  res.json({
    cards: cards
  });
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', service: 'Mock CDS Hooks Order-Sign Service' });
});

// Test endpoint - accepts the exact request format you provided
app.post('/test-request', (req, res) => {
  console.log('Test request received:', JSON.stringify(req.body, null, 2));
  
  // Forward to the medication service
  const mockResponse = {
    cards: [
      {
        uuid: 'test-card-001',
        summary: 'Test Card - Service Working',
        detail: `Received request for patient: ${req.body.context?.patientId || 'unknown'}. Hook: ${req.body.hook}. HookInstance: ${req.body.hookInstance}`,
        source: {
          label: 'Mock CDS Service - Test Mode',
          url: 'http://localhost:3001'
        },
        indicator: 'info'
      }
    ]
  };
  
  res.json(mockResponse);
});

app.listen(PORT, () => {
  console.log(`Mock CDS Hooks service running on http://localhost:${PORT}`);
  console.log(`Discovery endpoint: http://localhost:${PORT}/cds-services`);
  console.log('\nTo use with the sandbox:');
  console.log(`1. Click the "+" button in the sandbox header`);
  console.log(`2. Enter: http://localhost:${PORT}/cds-services`);
  console.log(`3. Click Save`);
  console.log(`4. Navigate to Rx Sign view\n`);
});

module.exports = app;
