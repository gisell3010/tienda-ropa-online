import { useEffect, useMemo, useState } from "react";
import { useAuth } from "../context/AuthContext";
import {
  actualizarPerfilCliente,
  eliminarDireccionCliente,
  listarDireccionesCliente,
  obtenerPerfilCliente,
  registrarDireccionCliente
} from "../services/clienteService";
import {
  listarDepartamentos,
  listarMunicipios
} from "../services/ubicacionService";

function ClientePerfilPage() {
  const { token } = useAuth();

  const [perfil, setPerfil] = useState(null);
  const [direcciones, setDirecciones] = useState([]);
  const [departamentos, setDepartamentos] = useState([]);
  const [municipios, setMunicipios] = useState([]);

  const [cargando, setCargando] = useState(true);
  const [guardandoPerfil, setGuardandoPerfil] = useState(false);
  const [guardandoDireccion, setGuardandoDireccion] = useState(false);
  const [eliminandoDireccionId, setEliminandoDireccionId] = useState(null);

  const [mensaje, setMensaje] = useState({
    tipo: "",
    texto: ""
  });

  const [formPerfil, setFormPerfil] = useState({
    nombre: "",
    telefono: "",
    correo: "",
    genero: "",
    fechaNacimiento: ""
  });

  const [formDireccion, setFormDireccion] = useState({
    departamentoId: "",
    municipioId: "",
    direccion: ""
  });

  const generoTexto = {
    F: "Femenino",
    M: "Masculino",
    O: "Otro"
  };

  const normalizarTexto = (texto) => {
    return String(texto || "")
      .trim()
      .toLowerCase()
      .replace(/\s+/g, " ");
  };

  const obtenerDireccionId = (direccion) => {
    return (
      direccion.direccionId ||
      direccion.dirId ||
      direccion.dir_id ||
      direccion.id
    );
  };

  const obtenerDepartamentoId = (departamento) => {
    return departamento.id || departamento.depId || departamento.dep_id;
  };

  const obtenerMunicipioId = (municipio) => {
    return municipio.id || municipio.munId || municipio.mun_id;
  };

  const telefonoValido = useMemo(() => {
    if (!formPerfil.telefono.trim()) return false;
    return /^3[0-9]{9}$/.test(formPerfil.telefono.trim());
  }, [formPerfil.telefono]);

  const perfilTieneCambios = useMemo(() => {
    if (!perfil) return false;

    return (
      normalizarTexto(formPerfil.nombre) !== normalizarTexto(perfil.nombre) ||
      normalizarTexto(formPerfil.telefono) !== normalizarTexto(perfil.telefono) ||
      String(formPerfil.genero || "") !== String(perfil.genero || "")
    );
  }, [formPerfil, perfil]);

  const formularioDireccionCompleto =
    Boolean(formDireccion.departamentoId) &&
    Boolean(formDireccion.municipioId) &&
    Boolean(formDireccion.direccion.trim());

  const direccionYaExiste = () => {
    const direccionNueva = normalizarTexto(formDireccion.direccion);
    const municipioNuevo = String(formDireccion.municipioId || "").trim();

    return direcciones.some((direccion) => {
      const direccionExistente = normalizarTexto(
        direccion.direccion || direccion.linea
      );

      const municipioExistente = String(
        direccion.municipioId ||
          direccion.munId ||
          direccion.mun_id ||
          direccion.municipio_id ||
          ""
      ).trim();

      return (
        direccionExistente === direccionNueva &&
        municipioExistente === municipioNuevo
      );
    });
  };

  const limpiarMensajeDespues = () => {
    window.setTimeout(() => {
      setMensaje({
        tipo: "",
        texto: ""
      });
    }, 4200);
  };

  const mostrarMensaje = (tipo, texto) => {
    setMensaje({ tipo, texto });
    limpiarMensajeDespues();
  };

  const cargarPerfilYDirecciones = async () => {
    try {
      setCargando(true);

      const [perfilData, direccionesData, departamentosData] =
        await Promise.all([
          obtenerPerfilCliente(token),
          listarDireccionesCliente(token),
          listarDepartamentos()
        ]);

      setPerfil(perfilData);
      setDirecciones(direccionesData || []);
      setDepartamentos(departamentosData || []);

      setFormPerfil({
        nombre: perfilData?.nombre || "",
        telefono: perfilData?.telefono || "",
        correo: perfilData?.correo || "",
        genero: perfilData?.genero || "",
        fechaNacimiento: perfilData?.fechaNacimiento || ""
      });
    } catch (error) {
      mostrarMensaje(
        "error",
        error.message || "No se pudo cargar la información del cliente."
      );
    } finally {
      setCargando(false);
    }
  };

  useEffect(() => {
    cargarPerfilYDirecciones();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    async function cargarMunicipios() {
      if (!formDireccion.departamentoId) {
        setMunicipios([]);
        return;
      }

      try {
        const data = await listarMunicipios(formDireccion.departamentoId);
        setMunicipios(data || []);
      } catch {
        setMunicipios([]);
        mostrarMensaje("error", "No se pudieron cargar los municipios.");
      }
    }

    cargarMunicipios();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [formDireccion.departamentoId]);

  const actualizarCampoPerfil = (evento) => {
    const { name, value } = evento.target;

    setFormPerfil((datosActuales) => ({
      ...datosActuales,
      [name]: value
    }));
  };

  const actualizarCampoDireccion = (evento) => {
    const { name, value } = evento.target;

    setFormDireccion((datosActuales) => {
      if (name === "departamentoId") {
        return {
          ...datosActuales,
          departamentoId: value,
          municipioId: ""
        };
      }

      return {
        ...datosActuales,
        [name]: value
      };
    });
  };

  const guardarPerfil = async (evento) => {
    evento.preventDefault();

    if (!formPerfil.nombre.trim()) {
      mostrarMensaje("error", "El nombre completo es obligatorio.");
      return;
    }

    if (!telefonoValido) {
      mostrarMensaje(
        "error",
        "El teléfono debe iniciar en 3 y tener 10 dígitos."
      );
      return;
    }

    if (!perfilTieneCambios) {
      mostrarMensaje("success", "No hay cambios pendientes por guardar.");
      return;
    }

    try {
      setGuardandoPerfil(true);

      const perfilActualizado = await actualizarPerfilCliente(
        {
          nombre: formPerfil.nombre.trim(),
          telefono: formPerfil.telefono.trim(),
          genero: formPerfil.genero,
          fechaNacimiento: formPerfil.fechaNacimiento
        },
        token
      );

      setPerfil(perfilActualizado);

      setFormPerfil({
        nombre: perfilActualizado?.nombre || "",
        telefono: perfilActualizado?.telefono || "",
        correo: perfilActualizado?.correo || "",
        genero: perfilActualizado?.genero || "",
        fechaNacimiento: perfilActualizado?.fechaNacimiento || ""
      });

      mostrarMensaje("success", "Perfil actualizado correctamente.");
    } catch (error) {
      mostrarMensaje(
        "error",
        error.message || "No se pudo actualizar el perfil."
      );
    } finally {
      setGuardandoPerfil(false);
    }
  };

  const guardarDireccion = async (evento) => {
    evento.preventDefault();

    if (!formDireccion.departamentoId) {
      mostrarMensaje("error", "Selecciona un departamento.");
      return;
    }

    if (!formDireccion.municipioId) {
      mostrarMensaje("error", "Selecciona un municipio.");
      return;
    }

    if (!formDireccion.direccion.trim()) {
      mostrarMensaje("error", "Ingresa la dirección.");
      return;
    }

    if (direccionYaExiste()) {
      mostrarMensaje("error", "Esta dirección ya está registrada.");
      return;
    }

    try {
      setGuardandoDireccion(true);

      const departamentoSeleccionado = departamentos.find(
        (departamento) =>
          String(obtenerDepartamentoId(departamento)) ===
          String(formDireccion.departamentoId)
      );

      const municipioSeleccionado = municipios.find(
        (municipio) =>
          String(obtenerMunicipioId(municipio)) ===
          String(formDireccion.municipioId)
      );

      await registrarDireccionCliente(
        {
          direccion: formDireccion.direccion.trim(),
          departamentoId: formDireccion.departamentoId,
          municipioId: formDireccion.municipioId,
          departamento: departamentoSeleccionado?.nombre || "",
          municipio: municipioSeleccionado?.nombre || ""
        },
        token
      );

      setFormDireccion({
        departamentoId: "",
        municipioId: "",
        direccion: ""
      });

      const direccionesActualizadas = await listarDireccionesCliente(token);
      setDirecciones(direccionesActualizadas || []);

      mostrarMensaje("success", "Dirección registrada correctamente.");
    } catch (error) {
      mostrarMensaje(
        "error",
        error.message || "No se pudo registrar la dirección."
      );
    } finally {
      setGuardandoDireccion(false);
    }
  };

  const eliminarDireccion = async (direccionId) => {
    const confirmar = window.confirm(
      "¿Seguro que deseas eliminar esta dirección?"
    );

    if (!confirmar) return;

    try {
      setEliminandoDireccionId(direccionId);

      await eliminarDireccionCliente(direccionId, token);

      const direccionesActualizadas = await listarDireccionesCliente(token);
      setDirecciones(direccionesActualizadas || []);

      mostrarMensaje("success", "Dirección eliminada correctamente.");
    } catch (error) {
      mostrarMensaje(
        "error",
        error.message || "No se pudo eliminar la dirección."
      );
    } finally {
      setEliminandoDireccionId(null);
    }
  };

  if (cargando) {
    return (
      <main className="cliente-page">
        <section className="cliente-card cliente-card--loading">
          <div className="cliente-skeleton cliente-skeleton--title" />
          <div className="cliente-skeleton" />
          <div className="cliente-skeleton" />
          <p>Cargando tu información...</p>
        </section>
      </main>
    );
  }

  return (
    <main className="cliente-page">
      <section className="cliente-header">
        <span className="cliente-header__label">Mi cuenta</span>

        <h1>Hola, {formPerfil.nombre || "bienvenida"}</h1>

        <p>
          Actualiza tus datos de contacto y administra tus direcciones de
          entrega.
        </p>
      </section>

      {mensaje.texto && (
        <div
          className={`cliente-message cliente-message--${mensaje.tipo}`}
          role="status"
          aria-live="polite"
        >
          {mensaje.texto}
        </div>
      )}

      <section className="cliente-layout">
        <form className="cliente-card cliente-form" onSubmit={guardarPerfil}>
          <div className="cliente-section-title">
            <div>
              <span>Información personal</span>
              <h2>Datos de contacto</h2>
            </div>

            <p>Los campos bloqueados son datos de registro.</p>
          </div>

          <label>
            Nombre completo
            <input
              type="text"
              name="nombre"
              value={formPerfil.nombre}
              onChange={actualizarCampoPerfil}
              placeholder="Ej: Laura Martínez"
              autoComplete="name"
            />
          </label>

          <label>
            Teléfono
            <input
              type="tel"
              name="telefono"
              value={formPerfil.telefono}
              onChange={actualizarCampoPerfil}
              placeholder="Ej: 3214567890"
              autoComplete="tel"
              aria-invalid={Boolean(formPerfil.telefono) && !telefonoValido}
            />

            {formPerfil.telefono && !telefonoValido && (
              <small className="cliente-field-help cliente-field-help--error">
                Debe iniciar en 3 y tener 10 dígitos.
              </small>
            )}
          </label>

          <label>
            Género
            <select
              name="genero"
              value={formPerfil.genero || ""}
              onChange={actualizarCampoPerfil}
            >
              <option value="">Selecciona</option>
              <option value="F">Femenino</option>
              <option value="M">Masculino</option>
              <option value="O">Otro</option>
            </select>
          </label>

          <div className="cliente-readonly-panel">
            <div>
              <span>Correo electrónico</span>
              <strong>{formPerfil.correo || "No registrado"}</strong>
              <small>Para cambiarlo se requiere validación de cuenta.</small>
            </div>

            <div>
              <span>Fecha de nacimiento</span>
              <strong>
                {formPerfil.fechaNacimiento || "No registrada"}
              </strong>
              <small>Dato de registro, no editable desde este formulario.</small>
            </div>
          </div>

          <button
            type="submit"
            disabled={
              guardandoPerfil ||
              !perfilTieneCambios ||
              !formPerfil.nombre.trim() ||
              !telefonoValido
            }
          >
            {guardandoPerfil
              ? "Guardando..."
              : perfilTieneCambios
                ? "Guardar perfil"
                : "Sin cambios"}
          </button>
        </form>

        <section className="cliente-card">
          <div className="cliente-section-title">
            <div>
              <span>Direcciones</span>
              <h2>Agregar dirección</h2>
            </div>

            <p>Selecciona primero el departamento y luego el municipio.</p>
          </div>

          <form className="cliente-form" onSubmit={guardarDireccion}>
            <label>
              Departamento
              <select
                name="departamentoId"
                value={formDireccion.departamentoId}
                onChange={actualizarCampoDireccion}
              >
                <option value="">Selecciona un departamento</option>
                {departamentos.map((departamento) => {
                  const departamentoId = obtenerDepartamentoId(departamento);

                  return (
                    <option key={departamentoId} value={departamentoId}>
                      {departamento.nombre}
                    </option>
                  );
                })}
              </select>
            </label>

            <label>
              Municipio
              <select
                name="municipioId"
                value={formDireccion.municipioId}
                onChange={actualizarCampoDireccion}
                disabled={!formDireccion.departamentoId}
              >
                <option value="">
                  {formDireccion.departamentoId
                    ? "Selecciona un municipio"
                    : "Primero selecciona un departamento"}
                </option>

                {municipios.map((municipio) => {
                  const municipioId = obtenerMunicipioId(municipio);

                  return (
                    <option key={municipioId} value={municipioId}>
                      {municipio.nombre}
                    </option>
                  );
                })}
              </select>
            </label>

            <label>
              Dirección
              <input
                type="text"
                name="direccion"
                value={formDireccion.direccion}
                onChange={actualizarCampoDireccion}
                placeholder="Ej: Carrera 20 # 11-78"
                autoComplete="street-address"
              />
            </label>

            <button
              type="submit"
              disabled={guardandoDireccion || !formularioDireccionCompleto}
            >
              {guardandoDireccion ? "Registrando..." : "Agregar dirección"}
            </button>
          </form>
        </section>
      </section>

      <section className="cliente-card cliente-addresses">
        <div className="cliente-section-title">
          <div>
            <span>Guardadas</span>
            <h2>Mis direcciones</h2>
          </div>

          <p>
            Usa esta lista para revisar o eliminar direcciones que ya no
            utilices.
          </p>
        </div>

        {direcciones.length === 0 ? (
          <div className="cliente-empty">
            <strong>No tienes direcciones registradas.</strong>
            <p>Agrega una dirección para completar tus compras más rápido.</p>
          </div>
        ) : (
          <div className="cliente-addresses__list">
            {direcciones.map((direccion) => {
              const direccionId = obtenerDireccionId(direccion);

              return (
                <article className="cliente-address" key={direccionId}>
                  <div className="cliente-address__icon" aria-hidden="true">
                    📍
                  </div>

                  <div className="cliente-address__content">
                    <h3>{direccion.direccion || direccion.linea}</h3>
                    <p>
                      {direccion.municipio || "Municipio no registrado"} /{" "}
                      {direccion.departamento || "Departamento no registrado"}
                    </p>
                  </div>

                  <button
                    type="button"
                    className="cliente-button-danger"
                    onClick={() => eliminarDireccion(direccionId)}
                    disabled={eliminandoDireccionId === direccionId}
                  >
                    {eliminandoDireccionId === direccionId
                      ? "Eliminando..."
                      : "Eliminar"}
                  </button>
                </article>
              );
            })}
          </div>
        )}
      </section>
    </main>
  );
}

export default ClientePerfilPage;