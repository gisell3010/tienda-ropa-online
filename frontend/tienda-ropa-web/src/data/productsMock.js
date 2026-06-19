import hoodieImg from "../assets/products/hoodie-1.png";
import hoodieHoverImg from "../assets/products/hoodie-2.png";

import pantalonCargoImg from "../assets/products/pantalon-cargo-1.png";
import pantalonCargoHoverImg from "../assets/products/pantalon-cargo-2.png";

import camisetaImg from "../assets/products/camiseta-1.png";
import camisetaHoverImg from "../assets/products/camiseta-2.png";

import tenisImg from "../assets/products/tenis-1.png";
import tenisHoverImg from "../assets/products/tenis-2.png";

import shortImg from "../assets/products/short-1.png";
import shortHoverImg from "../assets/products/short-2.png";

export const productsMock = [
  {
    id: 1,
    nombre: "Hoodie Oversize Streetwear",
    precio: 120000,
    imagen: hoodieImg,
    imagenHover: hoodieHoverImg,
    categoria: "Superior",
    categoriaId: 1,
    estilo: "Urban",
    estiloId: 3,
    tallas: ["M", "L", "XL"],
    colores: ["Negro", "Gris"],
    stock: 15
  },
  {
    id: 2,
    nombre: "Pantalón Cargo Casual",
    precio: 140000,
    imagen: pantalonCargoImg,
    imagenHover: pantalonCargoHoverImg,
    categoria: "Inferior",
    categoriaId: 2,
    estilo: "Casual",
    estiloId: 4,
    tallas: ["S", "M", "L"],
    colores: ["Oliva", "Negro"],
    stock: 20
  },
  {
    id: 3,
    nombre: "Camiseta Básica Algodón",
    precio: 45000,
    imagen: camisetaImg,
    imagenHover: camisetaHoverImg,
    categoria: "Superior",
    categoriaId: 1,
    estilo: "Casual",
    estiloId: 4,
    tallas: ["S", "M", "L", "XL"],
    colores: ["Blanco", "Negro", "Gris"],
    stock: 50
  },
  {
    id: 4,
    nombre: "Tenis Urban Classic",
    precio: 260000,
    imagen: tenisImg,
    imagenHover: tenisHoverImg,
    categoria: "Calzado",
    categoriaId: 3,
    estilo: "Urban",
    estiloId: 3,
    tallas: ["39", "40", "41"],
    colores: ["Blanco", "Negro"],
    stock: 8
  },
  {
    id: 5,
    nombre: "Short Deportivo Breathable",
    precio: 60000,
    imagen: shortImg,
    imagenHover: shortHoverImg,
    categoria: "Inferior",
    categoriaId: 2,
    estilo: "Deportivo",
    estiloId: 1,
    tallas: ["M", "L"],
    colores: ["Azul", "Gris"],
    stock: 0
  }
];