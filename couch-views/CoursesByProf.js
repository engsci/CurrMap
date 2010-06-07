function(doc) {
  if (doc.class == 'Person') {
    emit([doc._id, 0], doc);
  }
  else if (doc.class == 'Course') {
    for (var p in doc.people) {
      emit([p,1], {'name': doc.name, '_id': doc._id});
    }
  }
}