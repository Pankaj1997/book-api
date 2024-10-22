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
- [Deploy on an EC2 Instance](#deploy-on-ec2-instance)
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
git clone https://github.com/Pankaj1997/book-api.git
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
git clone https://github.com/Pankaj1997/book-api.git
cd app
```
2. Use `docker-compose` command
```
docker-compose up -d
```
## Run Using Helm
### Requirements
Make sure you have logged in to your kubernetes cluster and have `helm` package installed.

### Dependencies
* Accessible Kubernetes server
* Helm
  
### Installation
1. Clone the repository or download the source code:
```
git clone https://github.com/Pankaj1997/book-api.git
cd app
```
2. Use `kubectl` and `helm` command
```
kubectl create namespace {{ namespace }} && helm upgrade --install {{ release_name }} book-api-helm/ --namespace {{ namespace }}
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
## Deploy on Ec2 Instance
The terraform script will spawn a public ec2-instance and deploy the application using ansible and docker-compose.
### Requirements
* Make sure you have terraform installed.
* Configure your AWS credentials using `aws configure` or the environment variables
```
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="your-preferred-region"
```
* Use `ssh-keygen` command to create a SSH keypair
  
### Installation
1. Clone the repository or download the source code:
```
git clone https://github.com/Pankaj1997/book-api.git
cd tf-ec2
```
2. Configure your SSH key pair path in `vars.tf`
3. Use terraform commands to run
```
terraform init          # Initialize Terraform
terraform plan          # Plan changes and show what will be applied
terraform apply         # Apply the changes
```
### Output
You'll get an Output like the following:
```
Outputs:

API_URL = "API is running on http://13.201.55.0:5000"
```

## Deploy on EKS
The terraform script will spawn the following:
1. VPC with public and private subnets
2. EKS with private API server endpoint
3. Jump server in public subnet
4. login eks cluster using jump server and deploy the helm package on eks cluster.

### Requirements
* Make sure you have terraform installed.
* Configure your AWS credentials using `aws configure` or the environment variables
```
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="your-preferred-region"
```
* Use `ssh-keygen` command to create a SSH keypair
  
### Installation
1. Clone the repository or download the source code:
```
git clone https://github.com/Pankaj1997/book-api.git
cd tf-eks
```
2. Configure your SSH key pair path in `vars.tf`
3. Use terraform commands to run
```
terraform init          # Initialize Terraform
terraform plan          # Plan changes and show what will be applied
terraform apply         # Apply the changes
```
### Output
You'll get an Output like the following:
```
TASK [Retrieve LoadBalancer URL and save to /tmp/lb_ip.txt] ********************************************************************************************************************************************************************************************************
changed: [13.232.115.213]

TASK [Print LoadBalancer URL] **************************************************************************************************************************************************************************************************************************************
ok: [13.232.115.213] => {
    "msg": "The LoadBalancer URL is: a9c7e448fbdcf43b79d83a1bed052f91-ef93b5bce25d30b5.elb.ap-south-1.amazonaws.com"
}

PLAY RECAP *********************************************************************************************************************************************************************************************************************************************************
13.232.115.213             : ok=13   changed=5    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

### Sample Request
```
curl http://a9c7e448fbdcf43b79d83a1bed052f91-ef93b5bce25d30b5.elb.ap-south-1.amazonaws.com/allbooks
```

### Sample Response
```
{"1":{"author":"George Orwell","title":"1984","year":1949},"2":{"author":"Harper Lee","title":"To Kill a Mockingbird","year":1960}}
```