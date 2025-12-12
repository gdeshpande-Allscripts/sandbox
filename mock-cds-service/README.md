# Mock CDS Hooks Order-Sign Service

This is a mock CDS Hooks service that implements the `order-sign` hook according to the [CDS Hooks specification](https://cds-hooks.org/).

## Services Provided

### 1. Medication Order Sign Advisor
- **Hook**: `order-sign`
- **ID**: `medication-order-sign-advisor`
- **Description**: Provides coverage requirements and recommendations when signing medication orders
- **CRD Extension Support**: Full Da Vinci CRD coverage information extension
- **Cards Returned**:
  - **Prior Authorization Card** (warning) - When PA required
    - Coverage reference
    - `covered: conditional`, `pa-needed: auth-needed`
    - Required documentation: clinical + admin
    - Billing codes, allowed quantities, copay information
    - Qualification text with PA instructions
  - **Coverage Information Card** (info) - General coverage status
    - Coverage reference
    - `covered: covered`, `pa-needed: no-auth`
    - Gold card status when applicable
  - **Documentation Required Card** (warning) - When additional docs needed
    - Clinical documentation requirements
    - Concurrent review and appropriate use criteria flags

### 2. Contraindication Check
- **Hook**: `order-sign`
- **ID**: `order-sign-contraindication-check`
- **Description**: Checks for contraindications and provides coverage verification
- **CRD Extension Support**: Full Da Vinci CRD coverage information extension
- **Cards Returned**:
  - **No Contraindications Card** (info)
    - Coverage verified with no PA needed
    - Gold card status
    - Allowed quantities, copay details (in-network vs out-of-network)
    - Administrative documentation requirements

## CRD Coverage Extension Fields

All services support the Da Vinci CRD `davinci-crd.coverage-information` extension with:

### Required Fields (Cardinality 1..1):
- **coverage**: Reference to Coverage resource

### Optional Fields with Controlled Value Sets:
- **covered** (0..1): `covered` | `not-covered` | `conditional`
- **pa-needed** (0..1): `no-auth` | `auth-needed` | `satisfied` | `performpa` | `conditional`
- **doc-needed** (0..1): `clinical` | `admin` | `both` | `conditional`
- **doc-purpose** (0..*): `withpa` | `withclaim` | `withorder` | `retain-doc` | `OTH`
- **info-needed** (0..*): `performer` | `location` | `timeframe` | `contract-window` | `OTH`

### Additional Optional Fields:
- **billingCode** (0..*): Applicable billing/procedure codes
- **reason** (0..*): `gold-card` | `detail-code` | `other`
- **detail** (0..*): Coverage details with multiple data types
  - `allowed-quantity` (Quantity)
  - `allowed-period` (Period)
  - `in-network-copay` (String)
  - `out-network-copay` (String)
  - `auth-out-network-only` (Boolean)
  - `concurrent-review` (Boolean)
  - `appropriate-use-needed` (Boolean)
  - `other` (mixed types)
- **qualification**: Textual information about coverage requirements

## Setup

1. Install dependencies:
   ```bash
   cd mock-cds-service
   npm install
   ```

2. Start the service:
   ```bash
   npm start
   ```

   The service will run on `http://localhost:3001`

## Using with the Sandbox

1. Start this mock service (see Setup above)
2. Start the CDS Hooks Sandbox (in the parent directory):
   ```bash
   cd ..
   npm run dev
   ```
3. In the sandbox UI:
   - Click the **"+"** button (Add CDS Services) in the header
   - Enter: `http://localhost:3001/cds-services`
   - Click **Save**
4. Navigate to the **Rx Sign** view in the sandbox
5. Fill out a medication order and click **Sign Order**
6. The mock service will return CDS cards with recommendations

## CDS Hooks Specification Compliance

This service follows the CDS Hooks 1.0 specification:

- **Discovery Endpoint** (`GET /cds-services`): Returns service definitions
- **Service Endpoints** (`POST /cds-services/{id}`): Accept CDS Hooks requests and return cards
- **Request Format**: Expects `hook`, `hookInstance`, `context`, and optional `prefetch`
- **Response Format**: Returns `cards` array with proper card structure
- **Card Structure**: Includes `uuid`, `summary`, `detail`, `source`, `indicator`, `suggestions`, and `links`

## Customization

You can modify `server.js` to:
- Add more services
- Customize card content
- Add different types of suggestions and actions
- Implement more complex business logic
- Add authentication/authorization

## Testing

Test the discovery endpoint:
```bash
curl http://localhost:3001/cds-services
```

Test a service directly:
```bash
curl -X POST http://localhost:3001/cds-services/medication-order-sign-advisor \
  -H "Content-Type: application/json" \
  -d '{
    "hook": "order-sign",
    "hookInstance": "test-123",
    "context": {
      "patientId": "123",
      "draftOrders": {
        "resourceType": "Bundle",
        "entry": []
      }
    }
  }'
```
