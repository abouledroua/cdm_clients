class DetailsSpec {
  String nom, tel, adress, email, facebook, designation, image, photo;
  int idPerson, idSpecialite;
  DetailsSpec(
      {required this.idPerson,
      required this.idSpecialite,
      required this.photo,
      required this.nom,
      required this.image,
      required this.adress,
      required this.tel,
      required this.facebook,
      required this.designation,
      required this.email});
}
