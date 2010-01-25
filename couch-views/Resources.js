function(doc) {
  if (doc.class == 'Resource' ) {
    emit(doc._id, doc);
  }
}