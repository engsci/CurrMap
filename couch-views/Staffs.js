function(doc) {
  if (doc.class == 'Staff' ) {
    emit(doc._id, doc);
  }
}