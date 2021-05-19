# Swiss Covid Certificate - API documentation

- [Swiss Covid Certificate - API documentation](#swiss-covid-certificate---api-documentation)
  * [Introduction](#introduction)
    + [Links to EU digital green certificate documentation](#links-to-eu-digital-green-certificate-documentation)
  * [HOWTO use the API ?](#howto-use-the-api--)
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

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Introduction

The swiss covid certificate system can be used by authorized third party systems in order to generate, revoke and verify covid certificates compatible with the EU digital green certificate. This repository contains technical information about how to integrate third party systems.

The swiss covid certificate system is hosted and maintained by the [FOITT](https://www.bit.admin.ch/bit/en/home.html).

### Links to EU digital green certificate documentation

- [Specification of EU digital greeen certificate](https://ec.europa.eu/health/ehealth/covid-19_en)
- [Code repository of EU digital greeen certificate](https://github.com/eu-digital-green-certificates)

## HOWTO become a system intergrator using the API ?

If you are a primary system integrator, you can follow the following steps in order to use the generation and revocation API:

1. Indicate your interest to Covid-Zertifikat@bag.admin.ch 
2. Receive a test PKI certificate of type ["SwissGov Regular CA 01"](https://www.bit.admin.ch/bit/en/home/subsites/allgemeines-zur-swiss-government-pki/rootzertifikate/swiss-government-root-ca-ii.html) from [FOITT](https://www.bit.admin.ch/bit/en/home.html) so that the primary system integration can be developped and tested.
3. Sign an agreement with [FOITT](https://www.bit.admin.ch/bit/en/home.html). This is a condition for receiving a productive PKI certificate of type ["SwissGov Regular CA 01"](https://www.bit.admin.ch/bit/en/home/subsites/allgemeines-zur-swiss-government-pki/rootzertifikate/swiss-government-root-ca-ii.html).
4. If test is ok and agreement is signed, receive a production PKI certificate of type ["SwissGov Regular CA 01"](https://www.bit.admin.ch/bit/en/home/subsites/allgemeines-zur-swiss-government-pki/rootzertifikate/swiss-government-root-ca-ii.html) from [FOITT](https://www.bit.admin.ch/bit/en/home.html) in order to generate official swiss covid certificates.
5. REST API is free of charge. 
6. Batch processing is possible, but please avoid to request more than 2 covid certificates per second. In case of doubts, contact us with Covid-Zertifikat@bag.admin.ch 

## Third party system integration

In order to generate and revoke covid certificates, two ways are possible:
1. Use the [Web management UI](https://www.covidcertificate.admin.ch/). Only authorized users determined by the cantons can use the Web management UI.
2. Integrate the REST API within a primary system (system used by health professionals to manage vaccine, test and recovery information). Only authorized users determined by the cantons can use the REST API. Only primary systems determined by [FOITT](https://www.bit.admin.ch/bit/en/home.html) can access the REST API.

This documentation applies to the second use case presented above.

### Prerequisites in order to access the API

1. Only authorized users (natural persons) can access the generation and revocation API. Authorized users are determined by the swiss cantons or [FOPH](https://www.bag.admin.ch/bag/en/home.html).
2. Third party systems have to sign an agreement with [FOITT](https://www.bit.admin.ch/bit/en/home.html) in order to access the generation and revocation API.

### Integration achitecture

#### Integration with one-time password

The use of the generation and revocation API is done by using an one-time that has been loaded beforehand in the primary system and introduced in the REST API request. The one-time password has a limited validity.

![image](https://user-images.githubusercontent.com/319676/118590161-32374500-b7a2-11eb-8cb6-9395aacfa9de.png)

1. The authorized user previously registered and recognised by [eIAM](https://www.eiam.admin.ch/pages/eiam_en.html?c=eiam&l=en&ll=1) can obtain an one-time password by logging to the [Web management UI](https://www.covidcertificate.admin.ch/) page.
2. When the authorized user accesses the [Web management UI](https://www.covidcertificate.admin.ch/), its rights are verified by [eIAM](https://www.eiam.admin.ch/pages/eiam_en.html?c=eiam&l=en&ll=1).
3. The authorized user must insert the one-time password in the primary system so that it is transmitted when calling the REST API.
4. One-way authentication is used to create the TLS tunnel to protect the data transfer.
5. The one-time password is transferred so that the authorized user can be identified, as header of the request.
6. The content is hashed and signed with primary key of the "SwissGov Regular CA 01" certificate distributed to the primary system.
7. The dataset structured as JSON Schema is created and transported within the secured TLS tunnel.
8. The Management Service REST API checks the integrity of the data and signature received and the one-time password. 

#### Sequence diagram

![image](https://user-images.githubusercontent.com/319676/118361751-0db64f80-b58d-11eb-8f5a-fc7e193a1a00.png)

### Security architecture

#### Authorized user

The authorized users are onboarded in [eIAM](https://www.eiam.admin.ch/pages/eiam_en.html?c=eiam&l=en&ll=1) and can use a [CHLogin](https://www.eiam.admin.ch/?c=f!chlfaq!pub&l=en) or a [HIN](https://www.hin.ch/hin-anschluss/elektronische-identitaeten/) identity. They access the API by sending an OneTime password (OTP as [JSON Web Token - JWT](https://jwt.io/)) generated from the [Web management UI](https://www.covidcertificate.admin.ch/).

#### TLS tunnel

A TLS tunnel (single way authentication) is made between the primary system and the API gateway. One "SwissGov Regular CA 01" certificate is delivered to each primary system for this purpose.

#### Content signature

The content transferred to the REST API is signed with the "SwissGov Regular CA 01" certificate. The public key of the "SwissGov Regular CA 01" certificate has not to be added to the API request.

The process is the following:

1. Primary system creates a hash of the payload to be sent = data used to create the covid certificate (JSON data) or revocation data (JSON data).
2. Primary system encrypts this hash using the private key of the "SwissGov Regular CA 01" certificate used to authenticate itself. "SHA256withRSA" is the used algorithm. It corresponds with "RSASSA-PKCS1-v1_5" from the [RFC](https://datatracker.ietf.org/doc/html/rfc3447). 
3. The signed hash is placed in the request header.
4. Primary system places the JSON data (inclusive the one-time password) in the payload and sends the message to generation REST API or to revocation REST API. 

## Certificate data

3 types of covid certificate can be produced: vaccination, test or recovery. One covid certificate contains only one type. The personal data are common to all covid certificates. The other data are specific to the type of certificate.. 

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
- **language**: PDF language (together with the standard, which is english). Accepted languages are: de, it, fr, rm.
  - Format: ISO 639-1  two-letter codes, one per language for ISO 639 macrolanguage. 
  - Example: "de"

###  Specific vaccination data

Mandatory data:
- **medicinalProductCode**: name of the medicinal product as registered in the country. 
  - Format: string. Possible static values: 
    - "68267" represented by "COVID-19 Vaccine Moderna" in the covide certificate
    - "68225" represented by "Comirnaty" in the covide certificate
    - TBD
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

### Specific test data

Mandatory data:
- **typeCode**: type of test. This field is only mandatory when it is a PCR test. If given with manufacturerCode as well, they must match otherwise there will be a 400 BAD REQUEST.
  - Format: string. Possible static values:
    - "LP6464-4" for "Nucleic acid amplification with probe detection" (PCR)
    - "LP217198-3" for "Rapid immunoassay" (Antigen)
- **manufacturerCode**: test manufacturer code. This should only be sent when it is not a PCR test, otherwise there will be a 400 BAD REQUEST.
  - Format: string. Possible static values:
    - "344" for "SD BIOSENSOR Inc"
    - "1065" for "Becton Dickinson"
    - "1097" for "Quidel Corporation"
    - "1162" for "Nal von minden GmbH"
    - "1180" for "MEDsan GmbH"
    - "1218" for "Siemens Healthineers"
    - "1223" for "BIOSYNEX SWISS SA"
    - "1228" for "Shenzhen Microprofit Biotech Co., Ltd"
    - "1232" for "Abbott Rapid Diagnostics"
    - "1232" for "Abbott Rapid Diagnostics"
    - "1242" for "Bionote, Inc"
    - "1244" for "GenBody, Inc"
    - "1257" for "Hangzhou AllTest Biotech Co., Ltd"
    - "1268" for "LumiraDX UK Ltd"
    - "1271" for "Precision Biosensor, Inc"
    - "1276" for "Willi Fox GmbH"
    - "1278" for "Xiamen Boson Biotech Co. Ltd"
    - "1278" for "Xiamen Boson Biotech Co. Ltd."
    - "1304" for "AMEDA Labordiagnostik GmbH"
    - "1312" for "Guangzhou Wondfo Biotech Co., Ltd"
    - "1343" for "Zhejiang Orient Gene Biotech"
    - "1363" for "Hangzhou Clongene Biotech Co., Ltd"
    - "1481" for "MP Biomedicals Germany GmbH"
    - "1494" for "BIOSYNEX SWISS SA"
    - "1501" for "New Gene (Hangzhou) Bioengineering Co., Ltd"
    - "1604" for "Roche (SD BIOSENSOR)"
    - "1665" for "Inzek international trading bv"
    - "1739" for "Eurobio Scientific"
    - "1767" for "Healgen Scientific Limited Liability Company"
    - "1779" for "möLab GmbH"
    - "1833" for "AAZ-LMB"
    - "2010" for "Atlas Link Technology Co., Ltd., China"
    - "9999" for "LYSUN Covid 19 Antigen Rapid Test "
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

### Specific recovery data

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

See the [API doc](https://editor.swagger.io/?url=) to get technical information about the REST API.

#### Error list
There is a custom error body for the request if the server side parameter validation fails.
- `{451, "No vaccination data was specified"}`
- `{452, "No person data was specified"}`
- `{453, "Invalid dateOfBirth! Must be younger than 1900-01-01"}`
- `{454, "Invalid medicinal product"}`
- `{455, "Invalid number of doses"}`
- `{456, "Invalid vaccination date! Date cannot be in the future"}`
- `{457, "Invalid country of vaccination"}`
- `{458, "Invalid given name! Must not exceed 50 chars"}`
- `{459, "Invalid family name! Must not exceed 50 chars"}`
- `{460, "No test data was specified"}`
- `{461, "Invalid member state of test"}`
- `{462, "Invalid type of test and manufacturer code combination! Must either be a PCR Test type and no manufacturer code or give a manufacturer code and the antigen test type code."}`
- `{463, "Invalid testing center or facility"}`
- `{464, "Invalid sample or result date time! Sample date must be before current date and before result date"}`
- `{465, "No recovery data specified"}`
- `{466, "Invalid date of first positive test result"}`
- `{467, "Invalid country of test"}`
- `{468, "Country short form can not be mapped"}`
- `{469, "The given language does not match any of the supported languages: de, it, fr!"}`

As well as when the integrity check fails:
- `{"errorCode": 490, "errormessage": Integrity check failed. The body hash does not match the hash in the header.}`


