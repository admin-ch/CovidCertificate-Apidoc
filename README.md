# Swiss Covid Certificate - API documentation - WIP

- [Swiss Covid Certificate - API documentation - WIP](#swiss-covid-certificate---api-documentation---wip)
  * [Introduction](#introduction)
    + [Links to EU digital green certificate](#links-to-eu-digital-green-certificate)
  * [Third party system integration](#third-party-system-integration)
    + [Prerequisites](#prerequisites)
    + [Integration achitecture](#integration-achitecture)
      - [Integration with OneTime password](#integration-with-onetime-password)
      - [API sequence diagram](#api-sequence-diagram)
    + [Security architecture](#security-architecture)
      - [Authorized user](#authorized-user)
      - [TLS tunnel](#tls-tunnel)
      - [Content signature](#content-signature)
  * [Data](#data)
    + [Personal data](#personal-data)
    + [Vaccination data](#vaccination-data)
    + [Test data](#test-data)
    + [Recovery data](#recovery-data)
  * [API doc](#api-doc)
    + [Generation API](#generation-api)
      - [Error list](#error-list)
    + [Revokation API](#revokation-api)
    + [Verification API](#verification-api)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Introduction

The swiss covid certificate system can be used by authorized third party systems in order to generate, revoke and verify covid certificates compatible with the EU digital green certificate. This repository contains technical information about how to integrate third party systems.

The swiss covid certificate system is hosted and maintained by [FOITT](https://www.bit.admin.ch/bit/en/home.html).

### Links to EU digital green certificate
- [Specification of EU digital greeen certificate](https://ec.europa.eu/health/ehealth/covid-19_en)
- [Code repository of EU digital greeen certificate](https://github.com/eu-digital-green-certificates)

## Third party system integration

### Prerequisites

1. Only authorized users (natural persons) can access the generation and revokation API. Authorized users are determined by the swiss cantons or [FOPH](https://www.bag.admin.ch/bag/en/home.html).
2. Verification API is freely accessible.
3. Third party systems have to sign an agreement with [FOITT](https://www.bit.admin.ch/bit/en/home.html) in order to access the generation and verification API.

### Integration achitecture

#### Integration with OneTime password

![image](https://user-images.githubusercontent.com/319676/118224719-035c5e80-b484-11eb-8809-a90a7ea1548b.png)

The use of the generation and revokation API is done by using an OTP that has been loaded beforehand in the primary system and introduced in the REST API request. The OTP has a limited validity.

1. The authorized user previously registered and recognised by [eIAM](https://www.eiam.admin.ch/pages/eiam_en.html?c=eiam&l=en&ll=1) can obtain an OTP by logging to the [Web management UI](https://www.covidcertificate.admin.ch/) page.
2. When the authorized user accesses the [Web management UI](https://www.covidcertificate.admin.ch/), its rights are verified by [eIAM](https://www.eiam.admin.ch/pages/eiam_en.html?c=eiam&l=en&ll=1)
3. The authorized user must insert the OTP in the primary system so that it is transmitted when calling the REST API.
4. One-way authentication is used to create the TLS tunnel to protect the data transfer.
5. The OTP is transferred so that the authorized user can be identified, as header of the request.
6. The content is hashed and signed with primary key of the "SwissGov Regular CA 01" certificate distributed to the primary system.
7. The dataset structured as JSON Schema is created and transported within the secured TLS tunnel.
8. The Management Service REST API checks the integrity of the data and signature received and the OTP. 

#### API sequence diagram

![image](https://user-images.githubusercontent.com/319676/118361751-0db64f80-b58d-11eb-8f5a-fc7e193a1a00.png)

### Security architecture

#### Authorized user

The authorized users are onboarded in [eIAM](https://www.eiam.admin.ch/pages/eiam_en.html?c=eiam&l=en&ll=1) and can use a [CHLogin](https://www.eiam.admin.ch/?c=f!chlfaq!pub&l=en) or a [HIN](https://www.hin.ch/hin-anschluss/elektronische-identitaeten/) identity. They access the API by sending an OneTime password (OTP as [JSON Web Token - JWT](https://jwt.io/)) generated from the [Web management UI](https://www.covidcertificate.admin.ch/).

#### TLS tunnel

A TLS tunnel (single way authentication) is made between the primary system and the API gateway. One "SwissGov Regular CA 01" certificate is delivered to each primary system for this purpose.

#### Content signature

The content transferred to the REST API is signed with the "SwissGov Regular CA 01" certificate. The public key of the "SwissGov Regular CA 01" certificate has not to be added to the API request.

## Data

3 types of covid certificate can be produced: vaccination, test or recovery. One covid certificate contains only one type. The personal data are common to all certificate. The other data are specific to the type of certificate. 

### Personal data

Mandatory data appearing in all types of certificates:
- **familyName**: family name of the covid certificate owner. 
  - Format: string, maxLength: 50 CHAR. 
  - Example: "Federer"
- **givenName**: first name of the covid certificate owner. 
  - Format: string, maxLength: 50 CHAR. 
  - Example: "Roger"
- **dateOfBirth**: birthdate of the covid certificate owner. 
  - Format: ISO 8601 date without time. Range: can be between 1900-01-01 and 2099-12-31. Regexp: "[19|20][0-9][0-9]-(0[1-9]|1[0-2])-([0-2][1-9]|3[0|1])". 
  - Example: "1981-08-08"

### Vaccination data

Mandatory data:
- **medicinalProduct**: name of the medicinal product as registered in the country. 
  - Format: string. Possible static values: 
    - "68267" represented by "COVID-19 Vaccine Moderna" in the covide certificate
    - "68225" represented by "Comirnaty" in the covide certificate
    - "68235" represented by "COVID-19 Vaccine Janssen" in the covide certificate
- **numberOfDoses**: number in a series of doses.
  - Format: integer, range: from 1 to 9. 
- **totalNumberOfDoses**: total series of doses.
  - Format: integer, range: from 1 to 9. 
- **vaccinationDate**: date of vaccination. 
  - Format: ISO 8601 date without time. Range: can be between 1900-01-01 and 2099-12-31. Regexp: "[19|20][0-9][0-9]-(0[1-9]|1[0-2])-([0-2][1-9]|3[0|1])". 
  - Example: "2021-05-14"
- **countryOfVaccination**: the country in which the covid certificate owner has been vaccinated.
  - Format: string (2 chars according to ISO 3166 Country Codes).
  - Example: "CH" (for switzerland).

### Test data

Mandatory data:
- **testName**: name of the test. 
  - Format: string. 
  - Possible static values:
    - "PCR"
    - "Panbio COVID-19 Ag Test"
    - "AMP Rapid Test SARS-CoV-2 Ag"
    - "Veritor System Rapid Detection of SARS-CoV-2"
    - "SARS-CoV-2 Antigen Rapid Test Kit"
    - "Wantai SARS-CoV-2 Ag Rapid Test (FIA)"
    - "NowCheck COVID-19 Ag Test"
    - "BIOSYNEX COVID-19 Ag BSS"
    - "CerTest SARS-CoV-2 Card test"
    - "Genbody COVID-19 Ag Test"
    - "COVID-19 Ag Test Kit"
    - "Covid-19 Antigen Rapid Test Kit"
    - "Coronavirus Ag Rapid Test Cassette"
    - "COVID-19 Rapid Antigen Test (Colloidal Gold)"
    - "LumiraDx SARS-CoV-2 Ag Test"
    - "Rapid SARS-CoV-2 Antigen Test Card"
    - "NADAL COVID-19 Ag Test"
    - "ExDia COVID-19 Ag"
    - "SARS-CoV-2 Antigen Rapid Test"
    - "Sofia SARS Antigen FIA"
    - "COVID-19 Antigen Rapid Test Kit (Swab)"
    - "STANDARD F COVID-19 Ag FIA"
    - "STANDARD Q COVID-19 Ag Test"
    - "CLINITEST Rapid Covid-19 Antigen Test"
    - "Rapid SARS-CoV-2 Antigen Test Card"
    - "Coronavirus Ag Rapid Test Cassette (Swab)"
    - "BIOSYNEX COVID-19 Ag+ BSS"
    - "COVID-VIRO"
    - "NOVA Test SARS-CoV-2 Antigen Rapid Test Kit (Colloidal Gold Immunochromatography)"
    - "EBS SARS-CoV-2 Ag Rapid Test"
    - "Willi Fox COVID-19 Antigen rapid test"
    - "SARS-CoV-2 Spike Protein Test Kit (Fluorescence Immunoassay)"
    - "COVID-19 Antigen Rapid Test"
    - "Rapid SARS-CoV-2 Antigen Test Card"
    - "Wondof 2019-nCoV Antigen Test (Lateral Flow Method)"
    - "Biozek covid-19 Antigen Rapidtest BCOV-502"
    - "COVID-19 Antigen Detection Kit"
    - "SARS-CoV-2 Antigen Rapid Test"
    - "Panbio COVID-19 Ag Test"
    - "mö-screen Corona Antigen Testr"
- **sampleDateTime**: date and time of the test sample collection. 
  - Format: ISO 8601 date incl. time. 
  - Example: "1972-09-24T17:29:41.063Z"
- **resultDateTime**: date and time of the test result production (optional for rapid antigen test). 
  - Format: ISO 8601 date incl. time. 
  - Example: "1972-09-24T17:29:41.063Z"
- **testingCentreOrFacility**: name of centre or facility. 
  - Format: string, maxLength: 50 CHAR. 
  - Example: "Centre de test de Payerne"
- **memberStateOfTest**: the country in which the covid certificate owner has been tested.
  - Format: string (2 chars according to ISO 3166 Country Codes). 
  - Example: "CH" (for switzerland).

### Recovery data

Mandatory data:
- **dateOfFirstPositiveTestResult**: date when the sample for the test was collected that led to positive test obtained through a procedure established by a public health authority. 
  - Format: ISO 8601 date without time. Range: can be between 1900-01-01 and 2099-12-31. Regexp: "[19|20][0-9][0-9]-(0[1-9]|1[0-2])-([0-2][1-9]|3[0|1])".
  - Example: "2021-10-03"
- **countryOfTest**: the country in which the covid certificate owner has been tested. 
  - Format: string (2 chars according to ISO 3166 Country Codes).
  - Example: "CH" (for switzerland).

## API doc

### Generation API

The generation API allows to create 3 types of covid certificate: vaccination, test and recovery.

Please import the `api-doc.json` file in the https://editor.swagger.io to see the visualization.

#### Error list
There is a custom error body for the request if the server side parameter validation fails.
- `{451, "No vaccination data was specified"}`
- `{452, "No person data was specified"}`
- `{453, "Invalid dateOfBirth! Must be younger than 1900-01-01"}`
- `{454, "Invalid vaccine prophylaxis"}`
- `{455, "Invalid medicinal product"}`
- `{456, "Invalid marketing authorization holder"}`
- `{457, "Invalid number of doses"}`
- `{458, "Invalid vaccination date! Date cannot be in the future"}`
- `{459, "Invalid country of vaccination"}`
- `{460, "Invalid given name! Must not exceed 50 chars"}`
- `{461, "Invalid family name! Must not exceed 50 chars"}`
- `{462, "No test data was specified"}`
- `{463, "Invalid member state of test"}`
- `{464, "Invalid type of test"}`
- `{465, "Invalid test name"}`
- `{466, "Invalid test manufacturer"}`
- `{467, "Invalid testing center or facility"}`
- `{468, "Invalid sample or result date time! Sample date must be before current date and before result date"}`
- `{469, "No recovery data specified"}`
- `{470, "Invalid date of first positive test result"}`
- `{471, "Invalid country of test"}`

### Revokation API

### Verification API


