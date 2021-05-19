
# Swiss Covid Certificate-API documentation
## Table of contents
  * [Introduction](#introduction)
  * [Licensed entities](#licensed-entities)
  * [Third party system integration](#third-party-system-integration)
    + [Integration achitecture](#integration-achitecture)
      - [Authentication with one-time password](#authentication-with-one-time-password)
      - [Sequence diagram](#sequence-diagram)
    + [Security architecture](#security-architecture)
      - [Authorized user](#authorized-user)
      - [TLS tunnel](#tls-tunnel)
      - [Content signature](#content-signature)
  * [Certificate data](#certificate-data)
    + [Personal data (always present)](#personal-data--always-present-)
    + [Type specific data (one of, depending o)](#type-specific-data--one-of--depending-o-)
      - [Type: Vaccin](#type--vaccin)
      - [Type: Test](#type--test)
      - [Type: Recovery](#type--recovery)
  * [Technical specification](#technical-specification)
    + [Generation API](#generation-api)
      - [Error codes](#error-codes)
    + [Revocation API](#revocation-api)
    + [Verification API](#verification-api)
  * [What's next?](#what-s-next-)
    + [... say hello](#-say-hello)
    + [... start the integration](#start-the-integration)
    + [... go live](#-go-live)
    + [... furthermore](#-furthermore)
  * [Miscellaneous](#miscellaneous)
    + [EU digital green certificate](#eu-digital-green-certificate)

<small><i><a href='http://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Introduction

In the global context of COVID-19 pandemic, questions of certifications have arisen regarding the attestations of vaccine, negative test and immunitie.
It is in order to respond to this situation related to the certification of attestations, that the project **Swiss Covid Certificate** (abbr. *SCC*) was developed under a mandate from the [**Federal Office of Public Health**](https://www.bag.admin.ch/bag/en/home.html) (abbr. *FOPH*). This project provides a digital certification service aimed at licensed health professionals as well as the various licensed stakeholders which in collaboration with health professionals, store and manage informations related to Covid attestations. Beside the certification service, the *SCC* also provide a certificate revocation service and a certificate verification service.
A public mobile application has been developed to save these personal certificates in digital formats and another mobile application has also been developed to verifiy the validity of these certificates.

This certification is compatible with the [EU digital green certification](#links-to-eu-digital-green-certificate).

The *SCC* project is developed, hosted and maintained by the The[ **Federal Office of Information Technology, Systems and Telecommunication**](https://www.bit.admin.ch/bit/en/home.html) (abbr. *FOITT*)

This documentation is intended for integrators of third party systems who wish to integrate the *SCC* digital certification service to their system.

## Licensed entities
- Natural persons which have been licensed by their cantonal authorities or by the *FOPH*. They can use the service through a [Web management UI](https://www.covidcertificate.admin.ch/). In this documentation, those persons will be identified as **authorized users**.
- Third party systems which have been licensed by the *FOITT* (see [what's next?](#what-s-next-) to request an integration license).

## Third party system integration
### Integration achitecture
#### Authentication with one-time password
A one-time password (abbr. OTP) is required to authenticate to the service *API*. This *OTP* is provided to the authorized user through the [Web management UI](https://www.covidcertificate.admin.ch). The *OTP* must be stored in the primary system and used in the *REST API* request. The *OTP* has a limited validity.
![image](https://user-images.githubusercontent.com/319676/118590161-32374500-b7a2-11eb-8cb6-9395aacfa9de.png)

1. The authorized user previously registered and recognised by [eIAM](https://www.eiam.admin.ch/pages/eiam_en.html?c=eiam&l=en&ll=1) can obtain an OTP by logging to the [Web management UI](https://www.covidcertificate.admin.ch/) page.
2. When the authorized user access the [Web management UI](https://www.covidcertificate.admin.ch/), its rights are verified by [eIAM](https://www.eiam.admin.ch/pages/eiam_en.html?c=eiam&l=en&ll=1).
3. The authorized user must insert the OTP in the primary system so that it is transmitted when calling the REST API.
4. One-way authentication is used to create the TLS tunnel to protect the data transfer.
5. The OTP is transferred so that the authorized user can be identified, as header of the request.
6. The content is hashed and signed with primary key of the "SwissGov Regular CA 01" certificate distributed to the primary system.
7. The dataset structured as JSON Schema is created and transported within the secured TLS tunnel.
8. The Management Service REST API checks the integrity of the data and signature received and the OTP. 

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

1. Primary system creates a hash of the message to be sent = data used to create the covid certificate (JSON data) or revocation data (JSON data)
2. Primary system encrypts this hash using the private key of the "SwissGov Regular CA 01" certificate used to authenticate itself.
3. Primary system places the JSON data and the signed hash in the payload and sends the message to generation REST API or to revocation REST API. 
4. TODO Add JWT in HEADER ?

## Certificate data
A Covid certificate will always contain the covid certificate owner [personal data](#personal-data) plus a set of [type specific data](#type-specific-data]) (types: vaccination, test or recovery). 

[*: mandatory]
### Personal data (always present)
- **familyName***: family name of the covid certificate owner. 
  - Format: string, maxLength: 50 CHAR. 
  - Example: "Federer"
- **givenName***: first name of the covid certificate owner. 
  - Format: string, maxLength: 50 CHAR. 
  - Example: "Roger"
- **dateOfBirth***: birthdate of the covid certificate owner. 
  - Format: ISO 8601 date without time. Range: can be between 1900-01-01 and 2099-12-31. Regexp: "[19|20][0-9][0-9]-(0[1-9]|1[0-2])-([0-2][1-9]|3[0|1])". 
  - Example: "1981-08-08"
- **language***: PDF language (together with the standard, which is english). Accepted languages are: de, it, fr, rm.
  - Format: ISO 639-1  two-letter codes, one per language for ISO 639 macrolanguage. 
  - Example: "de"
### Type specific data (one of, depending o)

#### Type: Vaccin
- **medicinalProductCode***: name of the medicinal product as registered in the country. 
  - Format: string. Possible static values: 
    - "68267" represented by "COVID-19 Vaccine Moderna" in the covide certificate
    - "68225" represented by "Comirnaty" in the covide certificate
- **numberOfDoses***: number in a series of doses.
  - Format: integer, range: from 1 to 9. 
- **totalNumberOfDoses***: total series of doses.
  - Format: integer, range: from 1 to 9. 
- **vaccinationDate***: date of vaccination. 
  - Format: ISO 8601 date without time. Range: can be between 1900-01-01 and 2099-12-31. Regexp: "[19|20][0-9][0-9]-(0[1-9]|1[0-2])-([0-2][1-9]|3[0|1])". 
  - Example: "2021-05-14"
- **countryOfVaccination***: the country in which the covid certificate owner has been vaccinated.
  - Format: string (2 chars according to ISO 3166 Country Codes).
  - Example: "CH" (for switzerland).


#### Type: Test
- **typeCode***: type of test. This field is only mandatory when it is a PCR test. If given with manufacturerCode as well, they must match otherwise there will be a 400 BAD REQUEST.
  - Format: string. Possible static values:
    - "LP6464-4" for "Nucleic acid amplification with probe detection" (PCR)
    - "LP217198-3" for "Rapid immunoassay" (Antigen)
- **manufacturerCode***: test manufacturer code. This should only be sent when it is not a PCR test, otherwise there will be a 400 BAD REQUEST.
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
- **sampleDateTime***: date and time of the test sample collection. 
  - Format: ISO 8601 date incl. time. 
  - Example: "1972-09-24T17:29:41.063Z"
- **resultDateTime***: date and time of the test result production (optional for rapid antigen test). 
  - Format: ISO 8601 date incl. time. 
  - Example: "1972-09-24T17:29:41.063Z"
- **testingCentreOrFacility***: name of centre or facility. 
  - Format: string, maxLength: 50 CHAR. 
  - Example: "Centre de test de Payerne"
- **memberStateOfTest***: the country in which the covid certificate owner has been tested.
  - Format: string (2 chars according to ISO 3166 Country Codes). 
  - Example: "CH" (for switzerland).


#### Type: Recovery
- **dateOfFirstPositiveTestResult***: date when the sample for the test was collected that led to positive test obtained through a procedure established by a public health authority. 
  - Format: ISO 8601 date without time. Range: can be between 1900-01-01 and 2099-12-31. Regexp: "[19|20][0-9][0-9]-(0[1-9]|1[0-2])-([0-2][1-9]|3[0|1])".
  - Example: "2021-10-03"
- **countryOfTest***: the country in which the covid certificate owner has been tested. 
  - Format: string (2 chars according to ISO 3166 Country Codes).
  - Example: "CH" (for switzerland).

## Technical specification

### Generation API

Three types of covid certificate can be requested through the generation API:
- vaccination
- test
- recovery.

See the [API specifications](https://editor.swagger.io/?url=) for further informations.
#### Error codes
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

### Revocation API
???TBD???

### Verification API
???TBD???

## What's next?
### ... say hello
 - Address to covid-zertifikat@bag.admin.ch your interest to integrate the service.
### ... start the integration
- A test PKI certificate of type ["SwissGov Regular CA 01"](https://www.bit.admin.ch/bit/en/home/subsites/allgemeines-zur-swiss-government-pki/rootzertifikate/swiss-government-root-ca-ii.html) will be provided so that the primary system can access our test environment.
### ... go live
 - The integration with the test environnement must be successful.
 - The General Terms and Conditions from the **FOITT** are accepted. 
	 - A productive PKI certificate of type ["SwissGov Regular CA 01"](https://www.bit.admin.ch/bit/en/home/subsites/allgemeines-zur-swiss-government-pki/rootzertifikate/swiss-government-root-ca-ii.html) will be provided so that the primary system can access the productive environment and generate official certificates.

### ... furthermore
 - Revocations of certificates is also possible through the service.
 - The verification service is open.
 - The use of the service is free of charge. 
 - Certificate generation rate has to be limited to 2 certifications per second.

## Miscellaneous
### EU digital green certificate
- [Specification of EU digital greeen certificate](https://ec.europa.eu/health/ehealth/covid-19_en)
- [Code repository of EU digital greeen certificate](https://github.com/eu-digital-green-certificates)
