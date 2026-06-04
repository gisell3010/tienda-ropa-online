function Navbar() {
  return (
    <header className="navbar">
      <div className="navbar__brand">
        <h2>Tienda de ropa online</h2>
        <p>Moda urbana, casual y deportiva</p>
      </div>

      <nav className="navbar__links">
        <a href="#">Inicio</a>
        <a href="#">Catálogo</a>
        <a href="#">Novedades</a>
      </nav>
    </header>
  );
}

export default Navbar;

