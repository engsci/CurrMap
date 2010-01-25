function(doc) {
  if (doc.class == 'Collection' ) {
    emit(doc._id, doc);
  }
}