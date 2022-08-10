### Naratives
<details>

<summary>
As a user with an active internet connection
I want to be able to register for an account
</summary>

Data:-
 - email: Email
 - password: String

```
Given the user has an active internet connection
    When the user tries to register an account
    the application should present the registration screen
    - email + password
    upon successful registration - 
    - User should receive an email to verify their account.     
```

```
Given the user doesn't have an active internet connection
    When the user tries to register an account
    the application should present notification asking them turn on internet
```
</details>


<details>
<summary>
As a user with an active internet connection
I want to be able to login to my account
</summary>

Data:- 
- email: Email
- password: String

Response:- 
    StatusCode: - 200

    Data:- 
     created_at: Date
     updated_at: Date
     email: Email
     id: xid
     access_token: valid JWT


```
Given the user has an active internet connection 
    when the user tries to login by providing their email and password.
    - If the credentials are valid the user should be proceed to main screen
    - If the credentials are not valid the user should be prompted that their combination is not correct

```

</details>

<details>
<summary>
As a user with an active internet connection
I want to be able to create a shortened url
</summary>
Request
    Data: -
    - original_url : URL
    - custom_alias: String?
    - expires_on: Date (in the future, from now onwards)
    - keywords: [String]? - used for searching
    - description: String?

Response:
 - StatusCode: 201

  Data
  - id: String
  - user_id: xid
  - original_url: URL
  - custom_alias: String
  - shortcode: String
  - expires_on: Date
  - created_at: Date
  - updated_at: Date
  - keywords: [String]
  - hits: Int 

 - StatusCode: 400

  Data
  - error: String

```
Given a user has an active internet connection and has a valid token
    when the user tries to create a shortened url
    - if the provided information is correct / valid
    The user should receive a shortened url
    - if the provided information is not correct / not valid
    The user should receive an error response / message 
```
</details>

<details>
<summanry>
As a user with an active internet connection
I want to be able to fetch all of my shortened urls
</summary>
Response
    Statuscode: 200

    Data: - 
    [
        - id: String
        - user_id: String
        - original_url: URL
        - custom_alias: String
        - shortcode: String
        - expires_on: Date
        - created_at: Date
        - updated_at: Date
        - keywords: [String]
        - hits: Int 
    ]

```
Given a user has an active internet connection and has a valid token
    when the user tries to fetch all their shortened urls
    - The user should get all their shorted urls 
```
</details>

<details>
<summary>
As a user with an active internet connection and a valid token
I want to be able verify my shortened url
</summary>

Data: 
 Method: GET
 - urlPath : /:id

Response: 
    StatusCode: 200

    Data
    - id: String
    - user_id: String
    - original_url: URL
    - custom_alias: String
    - shortcode: String
    - expires_on: Date
    - created_at: Date
    - updated_at: Date
    - keywords: [String]
    - hits: Int 

</details>

<details>
<summary>
As a user with an active internet connection and a valid token
I want to be able delete my shortened url
</summary>

Data: 
 Method: DELETE
 - urlPath : /:id

Response: 
    StatusCode: 202

</details>