-- =========================================================
-- SCRIPT 03 - DATOS INICIALES
-- Proyecto: Tienda de ropa online
-- =========================================================

-- =========================================================
-- INSERT DEPARTAMENTOS
-- Códigos DANE
-- =========================================================

INSERT INTO departamentos (dep_id, nombre) VALUES
('91', 'Amazonas'),
('05', 'Antioquia'),
('81', 'Arauca'),
('08', 'Atlántico'),
('11', 'Bogotá, D.C.'),
('13', 'Bolívar'),
('15', 'Boyacá'),
('17', 'Caldas'),
('18', 'Caquetá'),
('85', 'Casanare'),
('19', 'Cauca'),
('20', 'Cesar'),
('27', 'Chocó'),
('23', 'Córdoba'),
('25', 'Cundinamarca'),
('94', 'Guainía'),
('95', 'Guaviare'),
('41', 'Huila'),
('44', 'La Guajira'),
('47', 'Magdalena'),
('50', 'Meta'),
('52', 'Nariño'),
('54', 'Norte de Santander'),
('86', 'Putumayo'),
('63', 'Quindío'),
('66', 'Risaralda'),
('88', 'San Andrés, Providencia y Santa Catalina'),
('68', 'Santander'),
('70', 'Sucre'),
('73', 'Tolima'),
('76', 'Valle del Cauca'),
('97', 'Vaupés'),
('99', 'Vichada')
ON CONFLICT (dep_id) DO NOTHING;


-- =========================================================
-- INSERT MUNICIPIOS
-- Códigos DANE
-- =========================================================

INSERT INTO municipios (mun_id, nombre, dep_id) VALUES
('91001', 'Leticia', '91'),
('05001', 'Medellín', '05'),
('81001', 'Arauca', '81'),
('08001', 'Barranquilla', '08'),
('11001', 'Bogotá, D.C.', '11'),
('13001', 'Cartagena', '13'),
('15001', 'Tunja', '15'),
('17001', 'Manizales', '17'),
('18001', 'Florencia', '18'),
('85001', 'Yopal', '85'),
('19001', 'Popayán', '19'),
('20001', 'Valledupar', '20'),
('27001', 'Quibdó', '27'),
('23001', 'Montería', '23'),
('25754', 'Soacha', '25'),
('94001', 'Inírida', '94'),
('95001', 'San José del Guaviare', '95'),
('41001', 'Neiva', '41'),
('44001', 'Riohacha', '44'),
('47001', 'Santa Marta', '47'),
('50001', 'Villavicencio', '50'),
('52001', 'Pasto', '52'),
('54001', 'Cúcuta', '54'),
('86001', 'Mocoa', '86'),
('63001', 'Armenia', '63'),
('66001', 'Pereira', '66'),
('88001', 'San Andrés', '88'),
('68001', 'Bucaramanga', '68'),
('70001', 'Sincelejo', '70'),
('73001', 'Ibagué', '73'),
('76001', 'Cali', '76'),
('97001', 'Mitú', '97'),
('99001', 'Puerto Carreño', '99')
ON CONFLICT (mun_id) DO NOTHING;