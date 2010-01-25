function(doc) {
  if (doc.class == 'Staff') {
    emit([doc._id, 0], doc);
  }
  else if (doc.class == 'Course') {
    for (var p in doc.staff) {
      emit([p,1], {'name': doc.name, '_id': doc._id});
    }
  }
}