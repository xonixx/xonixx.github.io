---
layout: post
title: 'TODO'
description: "The re-write of Spring Boot integration tests resulted in 10x execution speedup"
image: TODO
---

# TODO

_March 2023_

## Problem description

At [CML Team](https://www.cmlteam.com) we are building our own (yet internal) CRM system.
Technology-wise, it's a traditional web application with Java + Spring Boot + MySQL on the backend and React + Next.js on the frontend.

We have pretty good code coverage for the backend (reaching 80%) with tests, but the integration tests are (as expected) rather slow. It takes 20+ minutes to run on CI server. It's even slower running locally.

Needless to say, this slowness renders tests much less useful and helpful for the developers, since they practically can't run the tests locally often enough.

## Source of slowness

At CML Team we value integration/functional tests. So we tend to write tests with less mocks, tests that spans all layers of the (Java) application (controllers, services, repositories) -- down to (and including) the DB. The tests run on the real database (MySQL), not on often recommended H2. 

Overall, the idea is, the closer your tests follow _real_ (human) use-cases and real application setup, the higher chances to catch _real_ bugs.

Of course, we write unit-tests when applicable. But otherwise, we prefer end-to-end tests to tests for a specific controller, service or component.

It's clear that such tests are inherently slow, but they should not be _that_ slow! It was time to take a deeper look to understand what's going on.

***

Let's take a look at typical test we had there:

```java
@ExtendWith(SpringExtension.class)
@AutoConfigureMockMvc
@SpringBootTest
@DBRider
@DBUnit(
        leakHunter = true,
        mergeDataSets = true,
        caseSensitiveTableNames = true,
        allowEmptyFields = true)
class PersonHistoryServiceITest {
    @Test
    @WithUserDetails(value = "user1@mail.com", setupBefore = TestExecutionEvent.TEST_EXECUTION)
    @CleanDataBaseBeforeAndAfter("db_rider_data/controller/person/init_data.json")
    @ExpectedDataSet(
            value = "db_rider_data/history/person/add/data_after_save_person.json",
            ignoreCols = {"id", "person_id", "modified_at", "element_id"})
    void writeCreatingPersonToHistory() throws Exception {
        mockMvc
                .perform(
                        MockMvcRequestBuilders.post("/attendee/create")
                                .contentType(MediaType.APPLICATION_JSON)
                                .content(asJsonString(getPersonCreateRequestDtoNewPersonNewCompany())))
                .andExpect(status().is2xxSuccessful());
    }
}
```

The test uses the annotations from the [Database Rider](https://database-rider.github.io/database-rider/) project.

As you can see, this test has the following logic:
1. Firstly, it wipes the DB and fills it with initial data in `@CleanDataBaseBeforeAndAfter(".../init_data.json")`
2. Then, it runs the body of the test method, that executes a REST call to the API being tested
3. Finally, it tests the correctness of the final state of the DB via `@ExpectedDataSet(...)`

It appears that this test takes whopping 8+ seconds to execute:

![](optimize_tests1.png)

And if we take some thread dumps during the execution, we'll see, that major part of this time is spent in the Database Rider plugin applying the initial state to the DB (`init_data.json`):

![](optimize_tests2.png)

Here is an excerpt from `init_data.json`:

```json5
{
  "person": [
    {
      "id": 1,
      "country": "IE",
      "phone": "+111111111",
      "email": "john@test",
      "whatsapp": "1111111",
      "telegram": "@JohnS",
      "instagram": "@john_s",
      "facebook": "https://facebook.com/JohnS",
      "created_date": "1669125329768",
      "modified_date": "1669125329768",
      "first_name": "John",
      "last_name": "Smith",
      "outsourcing_history": "Found on clutch",
      "added_by": "IMPORTED_FROM_SPREADSHEET",
      "deleted": 0
    },
    // ... 
  ],
  "avatar": [
    {
      "id": 1,
      "person_id": 1,
      "photo_url": "https://web-summit/photos/1",
      "main": 1,
      "deleted": 0
    },
    {
      "id": 2,
      "person_id": 3,
      "photo_url": "https://web-summit/photos/2",
      "main": 1,
      "deleted": 0
    },
    // ...
  ],
  "company": [
    {
      "id": 1,
      "company_funding": 100,
      "company_valuation": 25,
      "employees_amount": 60,
      "linkedin": "http://new_linked_in/good",
      "name": "Good company",
      "website": "www.good-company.com"
    },
    // ...
  ],
  "person_company": [
    {
      "company_id": 1,
      "person_id": 1
    },
    {
      "company_id": 1,
      "person_id": 2
    },
    // ...
  ],
  "conference": [
    {
      "id": 1,
      "start_date": "2022-05-06",
      "end_date": "2022-05-09",
      "link": "www.some.conference",
      "location": "San Francisco",
      "conference_name": "First conference",
      "type": "ONLINE"
    },
  ]
  // ...
}
```

Overall, the dataset there is not big:

```
$ cat 'src/test/resources/db_rider_data/controller/person/init_data.json' | jq '[.[] | length] | add'
35
```

So it should be only 35 SQL inserts.

I have some guesses why this can take so long:

- Obviously, to turn `init_data.json` into a set of SQL inserts the Database Rider must determine the correct insertion order, according to entity relations (like foreign keys). So I guess, as a part of this routine it needs to first fetch the whole database metadata and then apply some topological sorting to the source dataset. 
- I'm not quite sure, how efficiently does the Database Rider do the inserts. Whether it in an auto-commit mode? Whether it does each insert in a separate transaction or not? 
- As `init_data.json` is shared among multiple tests, it, probably,  contains more data than needed for this particular test.


## The rewrite strategy

## Why the new approach is better?

## Results