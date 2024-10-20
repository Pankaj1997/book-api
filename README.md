# Flask Book Library API
This is a simple Book Library API built with Flask. The API allows users to perform the following operations:

* Get a book by ID: Retrieve details of a specific book by its ID.
* Get all books: Retrieve a list of all books in the library.
* Add a new book: Add a new book to the library.

## Table of Contents
- [Run Using Python](#run-using-python)
- [Run Using Docker Compose](#run-using-docker-compose)
- [Run Using Helm](#run-using-helm)
- [API Endpoints](#api-endpoints)
- [Error Handling](#error-handling)
- [Deploy on an EC2 Instance](#deploy-on-ec2)
- [Deploy on EKS](#deploy-on-eks)

## Run Using Python
### Requirements
Make sure you have Python installed (Python 3.9 recommended) and the required dependencies.

### Dependencies
The dependencies are listed in the `requirements.txt` file. Install them using:
`pip install -r requirements.txt`

### Installation
1. Clone the repository or download the source code:
```
git clone <repository-url>
cd app
```
2. Install the required Python packages:
```
pip install -r requirements.txt
```
3. Run the Flask application:
```
python app.py
```
## Run Using Docker Compose
### Requirements
Make sure you have Docker and Docker-Compose installed.

### Dependencies
* Docker Engine should be running
* Docker-compose binary should be present in $PATH
  
### Installation
1. Clone the repository or download the source code:
```
git clone <repository-url>
cd app
```
2. Use docker-compose command
```
docker-compose up -d
```

## Api Endpoints
### Get a Book by ID
* Endpoint: `/book/<id>`
* Method: `GET`
* Description: Retrieve details of a book by its ID.
* Example Curl Request:
  ```
  curl http://127.0.0.1:5000/book/1
  ```
* Example Response:
```
{
  "title": "1984",
  "author": "George Orwell",
  "year": 1949
}
```
### Get All Books
* Endpoint: `/allbooks`
* Method: `GET`
* Description: Retrieve a list of all books in the library.
* Example Curl Request:
  ```
  curl http://127.0.0.1:5000/allbooks
  ```
* Example Response:
```
{
  "1": {
    "title": "1984",
    "author": "George Orwell",
    "year": 1949
  },
  "2": {
    "title": "To Kill a Mockingbird",
    "author": "Harper Lee",
    "year": 1960
  }
}
```
### Add a New Book
* Endpoint: `/addbook`
* Method: `POST`
* Description: Add a new book to the library.
* Example Curl Request:
  ```
  curl -X POST http://127.0.0.1:5000/addbook \
  -H "Content-Type: application/json" \
  -d '{
  "title": "The Catcher in the Rye",
  "author": "J.D. Salinger",
  "year": 1951}'
  ```
* Example Response:
```
{
  "message": "Book added successfully",
  "book_id": 3
}
```
## Error Handling
### Invalid Data
If the request data is invalid or incomplete, the API will return a 400 Bad Request status with a detailed error message:
```
{
  "error": "Invalid data. Please provide the data in the following format:",
  "example": {
    "title": "The Catcher in the Rye",
    "author": "J.D. Salinger",
    "year": 1951
  }
}
```
