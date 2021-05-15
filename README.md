# Swiss Covid Certificate - API documentation - WIP

## Introduction

The swiss covid certificate system can be used by third party systems in order to generate, revoke and verify covid certificates compatible with the EU digital green certificate. This repository contains technical information about how to integrate third party systems.

The swiss covid certificate system is hosted and maintained by FOITT.

### Links to EU digital green certificate
- Specification of EU digital greeen certificate: https://ec.europa.eu/health/ehealth/covid-19_en
- Code repository of EU digital greeen certificate: https://github.com/eu-digital-green-certificates

## Third party system integration

### Prerequisites

1. Only authorized users (natural persons) can access the generation and revokation API. Authorized users are determined by the cantons or FOPH.
2. Verification API  is freely accessible.
3. Third party systems have to sign an agreement with FOITT in order to access the generation and verification API.

### Integration achitecture

#### Integration with OneTime password

In order to generate or revoke a covid certificate, an authorized user has first to generate an OneTime password which can then be used to access the generation and revokation APOI through a TLS tunnel:

![image](https://user-images.githubusercontent.com/319676/118224719-035c5e80-b484-11eb-8809-a90a7ea1548b.png)

### Security architecture

#### Authorized user

The authorized users are onboarded in EIAM and can use a CHLogin or a HIN identity.

#### TLS tunnel

A TLS tunnel is made between the primary system and the API. One "SwissGov Regular CA 01" certificate is delivered to each primary system for this purpose.

### Integration cookbook

TBD 

### Integration examples

TBD

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


