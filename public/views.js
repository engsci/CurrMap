var views = {
  "_id": "_design/testing",
  "views": {
    "Courses": {
      "map": "function(doc) { if (doc[\"_id\"].match(/[A-Z]{3}[0-9]{3}/i) ) { emit(doc[\"_id\"], doc); } }"
    }
  }
};