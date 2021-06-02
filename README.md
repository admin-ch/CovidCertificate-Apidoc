# Swiss Covid Certificate - API documentation

- [Swiss Covid Certificate - API documentation](#swiss-covid-certificate---api-documentation)
  * [Introduction](#introduction)
  * [HOWTO become a system integrator using the API ?](#howto-become-a-system-integrator-using-the-api--)
  * [Third party system integration](#third-party-system-integration)
    + [Prerequisites in order to access the API](#prerequisites-in-order-to-access-the-api)
    + [Integration architecture](#integration-architecture)
      - [Integration with one-time password](#integration-with-one-time-password)
      - [Sequence diagram](#sequence-diagram)
    + [Security architecture](#security-architecture)
      - [Authorized user](#authorized-user)
      - [TLS tunnel](#tls-tunnel)
      - [Content signature](#content-signature)
  * [Request - Certificate data](#request---certificate-data)
    + [Configuration data](#configuration-data)
    + [Personal data](#personal-data)
    + [Specific vaccination data](#specific-vaccination-data)
    + [Specific test data](#specific-test-data)
    + [Specific recovery data](#specific-recovery-data)
  * [Response - Covid certificate](#response---covid-certificate)
  * [API doc](#api-doc)
    + [Generation API](#generation-api)
    + [Revocation API](#revocation-api)
  * [References](#references)
    + [Links to EU digital green certificate documentation](#links-to-eu-digital-green-certificate-documentation)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Introduction

The swiss covid certificate system can be used by authorized third party systems in order to generate, revoke and verify covid certificates compatible with the EU digital green certificate. This repository contains technical information about how to integrate third party systems.

The swiss covid certificate system is hosted and maintained by the [FOITT](https://www.bit.admin.ch/bit/en/home.html).

## HOWTO become a system integrator using the API ?

If you are a primary system integrator, you can follow the following steps in order to use the generation and revocation API:

1. Indicate your interest to [Covid-Zertifikat@bag.admin.ch](mailto:Covid-Zertifikat@bag.admin.ch).
2. Receive a test PKI certificate of the type ["SwissGov Regular CA 01"](https://www.bit.admin.ch/bit/en/home/subsites/allgemeines-zur-swiss-government-pki/rootzertifikate/swiss-government-root-ca-ii.html) from [FOITT](https://www.bit.admin.ch/bit/en/home.html) so that the primary system integration can be developed and tested.
3. Sign an agreement with [FOITT](https://www.bit.admin.ch/bit/en/home.html). This is a condition for receiving a production PKI certificate of the type ["SwissGov Regular CA 01"](https://www.bit.admin.ch/bit/en/home/subsites/allgemeines-zur-swiss-government-pki/rootzertifikate/swiss-government-root-ca-ii.html).
4. If the test is successful and an agreement is signed, receive a production PKI certificate of the type ["SwissGov Regular CA 01"](https://www.bit.admin.ch/bit/en/home/subsites/allgemeines-zur-swiss-government-pki/rootzertifikate/swiss-government-root-ca-ii.html) from [FOITT](https://www.bit.admin.ch/bit/en/home.html) in order to generate official swiss covid certificates.
5. REST API is free of charge. 
6. Batch processing is possible, but please avoid to request more than 2 covid certificates per second. In case of doubts, contact us with [Covid-Zertifikat@bag.admin.ch](mailto:Covid-Zertifikat@bag.admin.ch).

## Third party system integration

There are two methods to generate and revoke covid certificates:
1. Use the Web management UI ([prod](https://www.covidcertificate.admin.ch/) - [test](https://www.covidcertificate-a.admin.ch/)). Only authorized users determined by the cantons can use the Web management UI ([prod](https://www.covidcertificate.admin.ch/) - [test](https://www.covidcertificate-a.admin.ch/)).
2. Integrate the REST API within a primary system (system used by health professionals to manage vaccine, test and recovery information). Only authorized users determined by the cantons can use the REST API. Only primary systems determined by [FOITT](https://www.bit.admin.ch/bit/en/home.html) can access the REST API.

This documentation applies to the second use case presented above.

### Prerequisites in order to access the API

1. Only authorized users (natural persons) can access the generation and revocation API. Authorized users are determined by the swiss cantons or [FOPH](https://www.bag.admin.ch/bag/en/home.html).
2. Third party systems have to sign an agreement with [FOITT](https://www.bit.admin.ch/bit/en/home.html) in order to access the generation and revocation API.

### Integration architecture

#### Integration with one-time password

To use the generation and revocation API a one-time password is required that can be obtained form the Web management UI ([prod](https://www.covidcertificate.admin.ch/) - [test](https://www.covidcertificate-a.admin.ch/)). This one-time password needs to be included in every REST API request and has a limited validity. After expiry a new one-time password has to be generated.

![image](https://user-images.githubusercontent.com/319676/118590161-32374500-b7a2-11eb-8cb6-9395aacfa9de.png)

1. The authorized user previously registered and recognized by [eIAM](https://www.eiam.admin.ch/pages/eiam_en.html?c=eiam&l=en&ll=1) can obtain a one-time password by signing in to the Web management UI ([prod](https://www.covidcertificate.admin.ch/) - [test](https://www.covidcertificate-a.admin.ch/)) page.
2. Upon signing in to the Web management UI ([prod](https://www.covidcertificate.admin.ch/) - [test](https://www.covidcertificate-a.admin.ch/)), the authorized users rights are verified by [eIAM](https://www.eiam.admin.ch/pages/eiam_en.html?c=eiam&l=en&ll=1).
3. The authorized user must insert the one-time password in the primary system so that it is transmitted when calling the REST API.
4. One-way authentication is used to create the TLS tunnel and therefor protect the data transfer.
5. The one-time password is transferred in the requests JSON payload. [See: API doc](https://editor.swagger.io/?url=https://raw.githubusercontent.com/admin-ch/CovidCertificate-Apidoc/main/api-doc.json)
6. The content is hashed and signed with the primary key of the "SwissGov Regular CA 01" certificate distributed to the primary system. [See: Content signature](#content-signature).
7. The dataset structured as JSON Schema is created and transported within the secured TLS tunnel.
8. The Management Service REST API checks the integrity of the data with the received signature and verifies the the one-time password. 

#### Sequence diagram

![image](https://user-images.githubusercontent.com/319676/118361751-0db64f80-b58d-11eb-8f5a-fc7e193a1a00.png)

### Security architecture

#### Authorized user

The authorized users are onboarded in [eIAM](https://www.eiam.admin.ch/pages/eiam_en.html?c=eiam&l=en&ll=1) and can use a [CHLogin](https://www.eiam.admin.ch/?c=f!chlfaq!pub&l=en) or a [HIN](https://www.hin.ch/hin-anschluss/elektronische-identitaeten/) identity. They access the API by sending an OneTime password (OTP as [JSON Web Token - JWT](https://jwt.io/)) generated from the Web management UI ([prod](https://www.covidcertificate.admin.ch/) - [test](https://www.covidcertificate-a.admin.ch/)).

#### TLS tunnel

A TLS tunnel (single way authentication) is made between the primary system and the API gateway. One "SwissGov Regular CA 01" certificate is delivered to each primary system for this purpose.

#### Content signature

The content transferred to the REST API is signed with the private key of the certificate issued by "SwissGov Regular CA 01". 

Given the JSON payload to be sent (data used to create the covid certificate or revocation data including the one-time password)), the process is as follows:

1. Primary system create a canonicalized text representation by removing all spaces, tabs, carriage returns and newlines from the payload. The regex `/[\n\r\t ]/gm` can be used.
2. Primary system encodes gets a UTF8 byte representation of that canonicalized text.
3. Primary system signs that byte representation using the algorithm "RSASSA-PKCS1-v1_5" from [RFC](https://datatracker.ietf.org/doc/html/rfc3447). Most implementations name the algorithm `SHA256withRSA`.
4. Primary system encodes the signature as base64 string.
5. Primary system places the base64 encoded signature in the request header `X-Signature`.

Java signature sample
```java
// load the key
PrivateKey privateKey = this.getCertificate();
// canonicalize
String normalizedJson = payload.replaceAll("[\\n\\r\\t ]", "");
byte[] bytes = normalizedJson.getBytes(StandardCharsets.UTF_8);
// sign
Signature signature = Signature.getInstance("SHA256withRSA");
signature.initSign(privateKey);
signature.update(bytes);
String signatureString = Base64.getEncoder().encodeToString(signature.sign());
```

.NET c# sample
```c#
// create RSA from certificate
X509Certificate2 cert = GetCertificate();
RSA rsaSignature = cert.GetRSAPrivateKey();

// normalize json
Regex normalizedJsonReplaceRegex = new Regex("[\\n\\r\\t ]");
string normalizedJson = normalizedJsonReplaceRegex.Replace(payload, string.Empty);

// sign
byte[] signatureBytes = rsaSignature.SignData(Encoding.UTF8.GetBytes(normalizedJson), HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);

// convert signature to Base64 string
string signatureString = Convert.ToBase64String(signatureBytes);
```

Node.js / TypeScript sample
```typescript
// load the key
const pemEncodedKey = fs.readFileSync(privateKeyFile)
const privateKeyObject = crypto.createPrivateKey(pemEncodedKey)
// canonicalize
const regex = /[\n\r\t ]/gm
const canonicalPayload = payload.replace(regex, '')
const bytes = Buffer.from(canonicalMessage, 'utf8')
// sign
const sign = crypto.createSign('RSA-SHA256')
sign.update(bytes)
const signature = sign.sign(privateKeyObject)
const base64encodedSignature = signature.toString('base64')
// set request header
headers['X-Signature'] = base64encodedSignature
```

## Request - Certificate data

3 types of covid certificate can be produced: vaccination, test or recovery. One covid certificate contains only one type. The configuration and personal data sections are the same for all covid certificates. The other data sections are specific to the type of certificate.

One generation request generates always one single covid certificate.

### Configuration data

Mandatory data necessary for all types of certificates:
- **language**: the national language of the covid certificate. Possible values:
  - Format: ISO 639-1  two-letter codes, one per language for ISO 639 macrolanguage. Possible static values: 
    - "DE"
    - "FR"
    - "IT"
    - "RM"   
- **otp**: the one time password which has to be generated in the [Web management UI (test environment)](https://www.covidcertificate-a.admin.ch/).
  - Format: string

### Personal data

Mandatory data appearing in all types of certificates:
- **familyName**: family name of the covid certificate owner. 
  - Format: string, maxLength: 50 CHAR. 
  - Example: "Muster"
- **givenName**: first name of the covid certificate owner. 
  - Format: string, maxLength: 50 CHAR. 
  - Example: "Hans"
- **dateOfBirth**: date of birth of the covid certificate owner. 
  - Format: ISO 8601 date without time. Range: can be between 1900-01-01 and 2099-12-31.
  - Example: "1981-08-09"

###  Specific vaccination data

Mandatory data:
- **medicinalProductCode**: name of the medicinal product as registered in the country. 
  - Format: string. The value set is defined [here](https://github.com/admin-ch/CovidCertificate-Examples/blob/main/valuesets/vaccine-medicinal-product.json). The value of the code has to be sent to the API
  - Example: "EU/1/20/1507" for a "COVID-19 Vaccine Moderna" vaccine
- **numberOfDoses**: number in a series of doses.
  - Format: integer, range: from 1 to 9. 
- **totalNumberOfDoses**: total series of doses.
  - Format: integer, range: from 1 to 9. 
- **vaccinationDate**: date of vaccination. 
  - Format: ISO 8601 date without time. Range: can be between 1900-01-01 and 2099-12-31. 
  - Example: "2021-05-14"
- **countryOfVaccination**: the country in which the covid certificate owner has been vaccinated.
  - Format: string (2 chars according to ISO 3166 Country Codes).
  - Example: "CH" (for switzerland).

### Specific test data

Mandatory data:
- **typeCode**: type of test. This field is only mandatory when it is a PCR test. If given with manufacturerCode as well, they must match otherwise there will be a 400 BAD REQUEST. 
  - Format: string. The value set is defined [here](https://github.com/admin-ch/CovidCertificate-Examples/blob/main/valuesets/test-type.json). The value of the code has to be sent to the API
  - Example: "LP6464-4" for a "Nucleic acid amplification with probe detection" type of test
- **manufacturerCode**: test manufacturer code. This should only be sent when it is not a PCR test, otherwise there will be a 400 BAD REQUEST.
  - Format: string. The value set is defined [here](https://github.com/admin-ch/CovidCertificate-Examples/blob/main/valuesets/test-manufacturer.json). The value of the code has to be sent to the API
  - Example: "1232" for a "Abbott Rapid Diagnostics" manufacturer
- **sampleDateTime**: date and time of the test sample collection. 
  - Format: ISO 8601 date incl. time. 
  - Example: "1972-09-24T17:29:41.063Z"
- **testingCentreOrFacility**: name of centre or facility. 
  - Format: string, maxLength: 50 CHAR. 
  - Example: "Centre de test de Payerne"
- **memberStateOfTest**: the country in which the covid certificate owner has been tested.
  - Format: string (2 chars according to ISO 3166 Country Codes). 
  - Example: "CH" (for switzerland).

### Specific recovery data

Mandatory data:
- **dateOfFirstPositiveTestResult**: date when the sample for the test was collected that led to positive test obtained through a procedure established by a public health authority. 
  - Format: ISO 8601 date without time. Range: can be between 1900-01-01 and 2099-12-31.
  - Example: "2021-10-03"
- **countryOfTest**: the country in which the covid certificate owner has been tested. 
  - Format: string (2 chars according to ISO 3166 Country Codes).
  - Example: "CH" (for switzerland).

## Response - Covid certificate

The response delivered by the API contains 3 fields:

- **pdf**: the pdf encoded with base64
- **qrCode**: the tamper-proof signed QRCode as PNG image encoded with base64
- **uvci**: the unique identifier of the certificate as string.

## API doc

See the [API doc](https://editor.swagger.io/?url=https://raw.githubusercontent.com/admin-ch/CovidCertificate-Apidoc/main/api-doc.json) to get technical information about the REST API and the error list.

### Generation API

The generation API allows to create 3 types of covid certificate: vaccination, test and recovery.

### Revocation API

The revocation API allows to revoke covid certificate based on the unique identifier UVCI.

## References

### Links to EU digital green certificate documentation

- [Specification of EU digital green certificate](https://ec.europa.eu/health/ehealth/covid-19_en)
- [Code repository of EU digital green certificate](https://github.com/eu-digital-green-certificates)
