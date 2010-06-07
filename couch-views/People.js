function(doc) {
  if (doc.class == 'Person' ) {
    emit(doc._id, doc);
  }
}