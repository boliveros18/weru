import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseMain {
  final String path;

  DatabaseMain({
    required this.path,
  });

  Future<Database> get db async {
    return openDatabase(
      join(path, 'weru.db'),
      onCreate: (db, version) async {
        return await onCreateTables(db);
      },
      version: 1,
    );
  }

  Future<void> onCreateTables(Database db) async {
    await db.execute(
      'CREATE TABLE Actividad (id INTEGER PRIMARY KEY, codigoExt TEXT, descripcion TEXT, costo INTEGER, valor INTEGER, idEstadoActividad INTEGER)',
    );
    await db.execute(
      'CREATE TABLE ActividadModelo (id INTEGER PRIMARY KEY, idActividad INTEGER, idModelo INTEGER)',
    );
    await db.execute(
      'CREATE TABLE ActividadServicio (id INTEGER PRIMARY KEY, idActividad INTEGER NOT NULL, idServicio TEXT NOT NULL, cantidad INTEGER, costo INTEGER, valor INTEGER, ejecutada INTEGER DEFAULT 0)',
    );
    await db.execute(
      'CREATE TABLE AdjuntoServicio (id INTEGER PRIMARY KEY, idServicio TEXT NOT NULL, idTecnico INTEGER, titulo TEXT, descripcion TEXT, tipo TEXT)',
    );
    await db.execute(
      'CREATE TABLE CategoriaIndicador (id INTEGER PRIMARY KEY, nombre TEXT, descripcion TEXT)',
    );
    await db.execute(
      'CREATE TABLE Ciudad (id INTEGER PRIMARY KEY, nombre TEXT NOT NULL, estado INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE Cliente (id INTEGER PRIMARY KEY, nombre TEXT NOT NULL, direccion TEXT NOT NULL, idCiudad INTEGER, telefono TEXT, celular TEXT, idTipoCliente INTEGER, idTipoDocumento TEXT, numDocumento TEXT, establecimiento TEXT, contacto TEXT, idEstado INTEGER, correo TEXT)',
    );
    await db.execute(
      'CREATE TABLE Diagnostico (id INTEGER PRIMARY KEY, descripcion TEXT, estado INTEGER)',
    );
    await db.execute(
      'CREATE TABLE DiagnosticoServicio (id INTEGER PRIMARY KEY, idServicio INTEGER, idDiagnostico INTEGER)',
    );
    await db.execute(
        'CREATE TABLE Equipo (id INTEGER PRIMARY KEY, serial TEXT, nombre TEXT, fechaCompra TEXT, fechaGarantia TEXT, idModelo INTEGER, idEstadoEquipo INTEGER, idProveedor INTEGER, idCliente INTEGER)');
    await db.execute(
      'CREATE TABLE EstadoServicio (id INTEGER PRIMARY KEY, nombre TEXT, descripcion TEXT)',
    );
    await db.execute(
      'CREATE TABLE Falla (id INTEGER PRIMARY KEY, descripcion TEXT, estado INTEGER)',
    );
    await db.execute(
      'CREATE TABLE FotoServicio (id INTEGER PRIMARY KEY, idServicio INTEGER, archivo TEXT, comentario TEXT)',
    );
    await db.execute(
      'CREATE TABLE Indicador (id INTEGER PRIMARY KEY, idEstadoIndicador INTEGER NOT NULL, descripcion TEXT, valorMin decimal(18, 3), valorMax decimal(18, 3), tipo TEXT, icono TEXT)',
    );
    await db.execute(
      'CREATE TABLE IndicadorModelo (id INTEGER PRIMARY KEY, idIndicador INTEGER, idModelo INTEGER)',
    );
    await db.execute(
      'CREATE TABLE IndicadorServicio (id INTEGER PRIMARY KEY, idIndicador INTEGER NOT NULL,idServicio TEXT NOT NULL,idTecnico INTEGER,valor TEXT)',
    );
    await db.execute(
      'CREATE TABLE Indirecto (id INTEGER PRIMARY KEY, idEstado INTEGER NOT NULL, descripcion TEXT NOT NULL, costo INTEGER, valor INTEGER)',
    );
    await db.execute(
      'CREATE TABLE IndirectoModelo (id INTEGER PRIMARY KEY, idIndirecto INTEGER, idModelo INTEGER)',
    );
    await db.execute(
      'CREATE TABLE IndirectoServicio (id INTEGER PRIMARY KEY, idIndirecto INTEGER NOT NULL, idServicio TEXT NOT NULL, cantidad INTEGER, costo INTEGER, valor INTEGER)',
    );
    await db.execute(
      'CREATE TABLE Item (id INTEGER PRIMARY KEY, SKU TEXT NOT NULL, descripcion TEXT, tipo INTEGER, costo INTEGER, precio INTEGER, idEstadoItem INTEGER, foto TEXT)',
    );
    await db.execute(
      'CREATE TABLE ItemActividadServicio (id INTEGER PRIMARY KEY, idItem INTEGER NOT NULL, idActividadServicio INTEGER NOT NULL, cantidadReq REAL DEFAULT 0)',
    );
    await db.execute(
      'CREATE TABLE ItemModelo (id INTEGER PRIMARY KEY, idItem INTEGER, idModelo INTEGER)',
    );
    await db.execute(
      'CREATE TABLE ItemServicio (id INTEGER PRIMARY KEY, idItem INTEGER NOT NULL, idServicio INTEGER NOT NULL, cantidad REAL DEFAULT 0, costo INTEGER, valor INTEGER, cantidadReq REAL DEFAULT 0, fechaUltimaVez TEXT, vidaUtil TEXT)',
    );
    await db.execute(
      'CREATE TABLE Maletin (id INTEGER PRIMARY KEY, idItem INTEGER NOT NULL, idTecnico INTEGER NOT NULL, cantidad REAL, costo REAL, valor REAL)',
    );
    await db.execute(
      'CREATE TABLE Modelo (id INTEGER PRIMARY KEY, descripcion TEXT)',
    );
    await db.execute(
      'CREATE TABLE Novedad (id INTEGER PRIMARY KEY, descripcion TEXT, estado INTEGER)',
    );
    await db.execute(
      'CREATE TABLE NovedadServicio (id INTEGER PRIMARY KEY, idServicio INTEGER, idNovedad INTEGER)',
    );
    await db.execute(
      'CREATE TABLE RegistroCamposAdicionales (id INTEGER PRIMARY KEY, idCamposAdicionales INTEGER NOT NULL, idRegistro INTEGER NOT NULL, valor INTEGER, nombre INTEGER)',
    );
    await db.execute(
      'CREATE TABLE Servicio (id INTEGER PRIMARY KEY, idTecnico INTEGER NOT NULL, idCliente INTEGER NOT NULL, idEstadoServicio int NOT NULL, nombre TEXT NULL, descripcion TEXT NULL, direccion TEXT NULL, idCiudad INTEGER NOT NULL, latitud decimal(11, 8) NOT NULL, longitud decimal(11, 8) NOT NULL, fechaInicio TEXT NULL, fechayhorainicio TEXT NULL, fechaModificacion TEXT NULL, fechaFin TEXT NULL, idEquipo INTEGER NULL, idFalla INTEGER NOT NULL, observacionReporte TEXT NULL, radicado TEXT NULL, idTipoServicio INTEGER NULL, cedulaFirma TEXT NULL, nombreFirma TEXT NULL, archivoFirma TEXT NULL, orden INTEGER DEFAULT 0, fechaLlegada TEXT NULL, comentarios TEXT NULL, consecutivo int NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE StageMessage (id INTEGER PRIMARY KEY AUTOINCREMENT, Message TEXT NOT NULL, MessageFamily TEXT NOT NULL, Address TEXT NOT NULL, Action TEXT NOT NULL, RetryCount INTEGER NOT NULL, Created DATETIME NOT NULL, Updated DATETIME NOT NULL, Proccesed INTEGER NOT NULL, ErrorDescription TEXT, Error INTEGER NOT NULL, BusinessId TEXT)',
    );
    await db.execute(
      'CREATE TABLE Tecnico (id INTEGER PRIMARY KEY, cedula TEXT NOT NULL, nombre TEXT NULL, idProveedor int NULL, idEstadoTecnico int NULL, usuario TEXT NOT NULL, clave TEXT NULL, telefono TEXT NULL, celular TEXT NULL, latitud REAL NULL, longitud REAL NULL, androidID TEXT NULL, fechaPulso TEXT NULL, versionApp TEXT NULL)',
    );
    await db.execute(
      'CREATE TABLE TipoCliente (id INTEGER PRIMARY KEY, nombre TEXT, descripcion TEXT)',
    );
    await db.execute(
      'CREATE TABLE TipoItem (id INTEGER PRIMARY KEY, descripcion TEXT)',
    );
    await db.execute(
      'CREATE TABLE TipoServicio (id INTEGER PRIMARY KEY, descripcion TEXT)',
    );
    await db.execute(
      'CREATE TABLE Titulos (id INTEGER PRIMARY KEY, idCampo INTEGER, campo TEXT, valor TEXT)',
    );
    await db.execute(
      'CREATE TABLE ValoresIndicador (id INTEGER PRIMARY KEY, idIndicador INTEGER, descripcion TEXT)',
    );
  }

  Future<Database> onCreate() async {
    return await db;
  }
}
