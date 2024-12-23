class Article{
  String nom;
  String description;
  num prix;
  String image;
  String categorie;

  Article(this.nom, this.description, this.prix, this.image, this.categorie);
  String prixEuro ()=> "$prix€";
}
