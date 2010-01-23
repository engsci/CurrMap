function (doc) {
  if (doc.class == 'Course' ) {
    emit(doc._id, doc);
  }
}