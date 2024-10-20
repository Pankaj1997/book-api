from flask import Flask, jsonify, request, abort

app = Flask(__name__)

# In-memory database (dictionary) to store books
books_db = {
    1: {"title": "1984", "author": "George Orwell", "year": 1949},
    2: {"title": "To Kill a Mockingbird", "author": "Harper Lee", "year": 1960}
}

# Custom exception for invalid data
class InvalidBookData(Exception):
    pass

# Error handler for InvalidBookData exception
@app.errorhandler(InvalidBookData)
def handle_invalid_book_data(error):
    response = jsonify({
        "error": str(error),
        "example": {
            "title": "The Catcher in the Rye",
            "author": "J.D. Salinger",
            "year": 1951
        }
    })
    response.status_code = 400
    return response

# Get a book by ID
@app.route('/book/<int:id>', methods=['GET'])
def get_book_by_id(id):
    book = books_db.get(id)
    if not book:
        abort(404, description="Book not found")
    return jsonify(book)

# Get all books
@app.route('/allbooks', methods=['GET'])
def get_all_books():
    return jsonify(books_db)

# Add a new book
@app.route('/addbook', methods=['POST'])
def add_book():
    try:
        if not request.json:
            raise InvalidBookData("Request data must be in JSON format.")
        
        # Ensure all required fields are present
        if not all(key in request.json for key in ['title', 'author', 'year']):
            raise InvalidBookData("Missing required fields: 'title', 'author', and 'year'.")
        
        # Validate the year field is an integer
        if not isinstance(request.json['year'], int):
            raise InvalidBookData("Field 'year' must be an integer.")
        
        new_id = max(books_db.keys()) + 1
        book = {
            "title": request.json['title'],
            "author": request.json['author'],
            "year": request.json['year']
        }
        books_db[new_id] = book
        return jsonify({"message": "Book added successfully", "book_id": new_id}), 201
    
    except InvalidBookData as e:
        raise e

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
