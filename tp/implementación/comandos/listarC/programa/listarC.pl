#!/usr/bin/perl -w

# Estoy en UTF8: sí

#
# $Id$
#

#
# Interacción de este programa con el resto del sistema:
#
#  Necesita de las siguientes variables de entorno:
#   * GRUPO, path raiz del sistema
#   * DATAMAE, path donde están ubicados los archivos maestros, indexando desde $GRUPO
#
#  Necesita de los archivos:
#   * $GRUPO/ya/encuestas.sum
#   * $GRUPO/$DATAMAE/encuestas.mae
#   * $GRUPO/$DATAMAE/encuestadores.mae
#
#  Los informes se graban en el directorio: $GRUPO/ya/
#
#  No escribe logs
#

#
# PARÁMETROS
#
# NINGUNO de los valores de los parámetros es case-sensitive.
# TODOS los valores de los parámetros pueden expresarse como expresiones regulares.
#
# Los parámetros pueden ser:
#  -enc, --encuestador
#  -cod, --código-de-encuesta
#  -n, --nro-de-encuesta
#  -m, --modalidad
#  -h, --help
#  -a, --agrupamiento (Con esta variable se controla el agrupamiento que se hará de las encuestas seleccionadas)
#
# Valores posibles para los parámetros:
#  * enc, cod:  1, 2, n, * (todos)
#  * n:         nro de encuesta, un rango de ellas, * (todos)
#  * m:         e (electrónica), t (telefónica), c (correo convencional) o p (presencial)
#  * a:         x-cod, x-enc o * (ambos)
#
# Las opciones pueden ser:
#  -c (resuelve la consulta y muestra resultados por pantalla, no graba en archivo)
#  -e (resuelve y emite un informe)
#
# Invocaciones de ejemplo:
#  Las siguientes 4 invocaciones darán el mismo reporte:
#   * perl $GRUPO/inst/listarC.pl -enc estepano
#   * perl $GRUPO/inst/listarC.pl -enc eStEPanO
#   * perl $GRUPO/inst/listarC.pl -enc estepan.
#   * perl $GRUPO/inst/listarC.pl -enc ^estepano$
#  Para que muestre los resultados sólo por pantalla:
#   * perl $GRUPO/inst/listarC.pl -c
#  Para que los resultados los ponga sólo en el archvio de resultados:
#   * perl $GRUPO/inst/listarC.pl -e
#  Para que los resultados los muestre por pantalla y los ponga en el archvio de resultados:
#   * perl $GRUPO/inst/listarC.pl -e -c
#  Para que busque las encuestas de modalidad electrónica y de correo convencional:
#   * perl $GRUPO/inst/listarC.pl -m e -m c
#  Para que busque todo:
#   * perl $GRUPO/inst/listarC.pl
#

#
# Links más consultados:
#  * http://www.perl.org
#  * http://www.perlhowto.com
#  * http://www.epic-ide.org
#


#
# Variables seteadas a partir de los argumentos recibidos por el programa
                                        # parámetro que lo controla
my @filtroSeleccionEncuestadores = ();  # -enc, --encuestador
my @filtroSeleccionCodigoEncuesta = (); # -cod, --código-de-encuesta
my @filtroSeleccionNroEncuesta = ();    # -n, --nro-de-encuesta
my @filtroSeleccionModalidad = ();      # -m, --modalidad
my $mostrarResultadosEnPantalla = 1;    # -c (resuelve la consulta y muestra resultados por pantalla, no graba en archivo)
my $guardarResultadosEnArchivo = 1;     # -e (resuelve y emite un informe)
my $agrupamiento = "*";                 # -a, --agrupamiento (Con esta variable se controla el agrupamiento que se hará de las encuestas seleccionadas. Debe tomar alguno de estos tres valores: "x-cod", "x-enc" o "*")


# Hash'es en los que almacenaré los datos obtenidos de los archivos maestros
my %infoEncuestasMaestro = ();
my %infoEncuestadoresMaestro = ();

# Hash en el que almacenaré las encuestas seleccionadas por los criterios del "query"
my %encuestasSeleccionadas = ();


#
# Variables de entorno
my $pathArchivosMaestros = $ENV{"GRUPO"}.$ENV{"DATAMAE"}."/";
my $pathArchivosYa = $ENV{"GRUPO"}."/ya/";
my $pathArchivosResultados = $ENV{"GRUPO"}."/ya/";
my $pathYNombreArchivoEncuestasMaestro = $pathArchivosMaestros."encuestas.mae";
my $pathYNombreArchivoEncuestadoresMaestro = $pathArchivosMaestros."encuestadores.mae";
my $pathYNombreArchivoEncuestasSumarizadas = $pathArchivosYa."encuestas.sum";
my $pathYNombreArchivoResultados = $pathArchivosResultados."resultados-";


#
# Funciones
#
sub DEBUG{
	# print @_;
}

sub MOSTRAR_ERROR{
	print @_;
}

sub MOSTRAR_EN_PANTALLA{
	print @_;
}

# necesita de $pathYNombreArchivoResultados
# recibe $idArchivo, $strAGuardar
sub GUARDAR_EN_ARCHIVO{
	$idArchivo = $_[0];
	$strAGuardar = $_[1];

	open(FILE_HANDLER_ARCHIVO_SALIDA, ">>".$pathYNombreArchivoResultados.$idArchivo);
	print FILE_HANDLER_ARCHIVO_SALIDA $strAGuardar;
	close(FILE_HANDLER_ARCHIVO_SALIDA);
}

sub mostrarAyuda{
	print "\n====== AYUDA ======\n";
	print "\nNINGUNO de los parámetros ni opciones es case-sensitive.\n";
	print "\nTODOS los valores de los parámetros pueden expresarse como expresiones regulares.\n";
	print "Los parámetros pueden ser:\n";
	print " -enc, --encuestador\n";
	print " -cod, --código-de-encuesta\n";
	print " -n, --nro-de-encuesta\n";
	print " -m, --modalidad\n";
	print " -a, --agrupamiento\n";
	print " -h, --help\n";
	
	print "\n";
	
	print "Valores posibles para:\n";
	print " * los parámetros enc, cod:  1, 2, n, * (todos)\n";
	print " * el parámetro n:           nro de encuesta, un rango de ellas, * (todos)\n";
	print " * el parámetro m:           e (electrónica), t (telefónica), c (correo convencional), p (presencial), * (todas)\n";
	print " * el parámetro a:           x-cod, x-enc o *\n";
	
	print "\n";

	print "Valores default para:\n";
	print " * los parámetros enc, cod, m:  * (todos)\n";
	print " * el parámetro n:              * (todos)\n";
	print " * el parámetro m:              todas las modalidades\n";
	print " * el parámetro a:              ambos\n";
	
	print "\n";
	
	print "Las opciones pueden ser:\n";
	print " -c (resuelve la consulta y muestra resultados por pantalla, no graba en archivo)\n";
	print " -e (resuelve y emite un informe)\n";
	
	print "\n==== FIN AYUDA ====\n";
}

# recibe @ARGV
sub procesarArgumentos{
	use Switch;

	$estado_procesador_de_argumentos = "recibiendo-tipo-parametro";

	DEBUG "Parametros: ";
	
	foreach $param (@_) {
	
		switch ($estado_procesador_de_argumentos){
			case("recibiendo-tipo-parametro") {
				switch(lc($param)){
					case["-enc", "--encuestador"]{
						DEBUG("\$param = $param\n");
						$estado_procesador_de_argumentos = "recibiendo-valor-encuestador";
					}
	
					case["-cod", "--código-de-encuesta"]{
						DEBUG "\$param = $param\n";
						$estado_procesador_de_argumentos = "recibiendo-valor-codigo-encuesta";
					}
			
					case["-n", "--nro-de-encuesta"]{
						DEBUG "\$param = $param\n";
						$estado_procesador_de_argumentos = "recibiendo-valor-nro-encuesta";
					}
					
					case["-m", "--modalidad"]{
						DEBUG "\$param = $param\n";
						$estado_procesador_de_argumentos = "recibiendo-valor-modalidad";
					}
			
					case["-a", "--agrupamiento"]{
						DEBUG "\$param = $param\n";
						$estado_procesador_de_argumentos = "recibiendo-valor-agrupamiento";
					}
			
					case["-h", "--help"]{
						DEBUG "\$param = $param\n";
						mostrarAyuda();
						return 1;
					}
			
					case("-c"){
						DEBUG "\$param = $param\n";
						$mostrarResultadosEnPantalla = 1;
					}
	
					case("-e"){
						DEBUG "\$param = $param\n";
						$guardarResultadosEnArchivo = 1;
					}
					
					case["-ce", "-ec"]{
						DEBUG "\$param = $param\n";
						$mostrarResultadosEnPantalla = 1;
						$guardarResultadosEnArchivo = 1;
					}

					else{
						MOSTRAR_ERROR "ERROR: argumento desconocido!, \$param=$param\n";
						return 1;
					}
				}
			}
	
			case("recibiendo-valor-encuestador"){
				push(@filtroSeleccionEncuestadores, $param);
				$estado_procesador_de_argumentos = "recibiendo-tipo-parametro";
			}
	
			case("recibiendo-valor-codigo-encuesta"){
				push(@filtroSeleccionCodigoEncuesta, $param);
				$estado_procesador_de_argumentos = "recibiendo-tipo-parametro";
			}
	
			case("recibiendo-valor-nro-encuesta"){
				push(@filtroSeleccionNroEncuesta, $param);
				$estado_procesador_de_argumentos = "recibiendo-tipo-parametro";
			}
	
			case("recibiendo-valor-modalidad"){
				push(@filtroSeleccionModalidad, $param);
				$estado_procesador_de_argumentos = "recibiendo-tipo-parametro";
			}
			
			case("recibiendo-valor-agrupamiento"){
				$agrupamiento = $param;
			}
	
			else{
				MOSTRAR_ERROR "\ERROR: estado desconocido, \$estado_procesador_de_argumentos=$estado_procesador_de_argumentos\n";
				return 1;
			}
		}
	}
	DEBUG "\n";

	# Si alguno no fue seteado por los parámetros recibidos, entonces le seteo el valor por default	
	if(!(@filtroSeleccionEncuestadores)){
		$filtroSeleccionEncuestadores[0] = "*";
	}
	if(!(@filtroSeleccionCodigoEncuesta)){
		$filtroSeleccionCodigoEncuesta[0] = "*";
	}
	if(!(@filtroSeleccionNroEncuesta)){
		$filtroSeleccionNroEncuesta[0] = "*";
	}
	if(!(@filtroSeleccionModalidad)){
		$filtroSeleccionModalidad[0] = "*";
	}
	
	return 0;
}

# necesita de @filtroSeleccionEncuestadores
# recibe $encuestador
sub esEncuestadorSeleccionado{
	DEBUG "@filtroSeleccionEncuestadores \n";
	
	# si el array tiene el valor default, salgo inmediatamente contestando true al matching
	if($filtroSeleccionEncuestadores[0] eq "*"){
		return 1;
	}
	
	$encuestador = $_[0];

	foreach $filtro (@filtroSeleccionEncuestadores){	
		if(lc($encuestador) eq lc($filtro) || lc($encuestador) =~ /$filtro/){
			return 1;
		}
	}

	return 0;
}

# necesita de $filtroSeleccionNroEncuesta
# recibe $nroEncuesta
sub esNroEncuestaSeleccionada{
	DEBUG "@filtroSeleccionNroEncuesta \n";
	
	# si el array tiene el valor default, salgo inmediatamente contestando true al matching
	if($filtroSeleccionNroEncuesta[0] eq "*"){
		return 1;
	}
	
	$nroEncuesta = $_[0];

	foreach $filtro (@filtroSeleccionNroEncuesta){	
		if(lc($nroEncuesta) eq lc($filtro) || lc($nroEncuesta) =~ /$filtro/){
			return 1;
		}
	}

	return 0;
}

# necesita de $filtroSeleccionCodigoEncuesta
# recibe $codigoEncuesta
sub esCodigoEncuestaSeleccionado{
	DEBUG "@filtroSeleccionCodigoEncuesta \n";
	
	# si el array tiene el valor default, salgo inmediatamente contestando true al matching
	if($filtroSeleccionCodigoEncuesta[0] eq "*"){
		return 1;
	}
	
	$codigoEncuesta = $_[0];

	foreach $filtro (@filtroSeleccionCodigoEncuesta){	
		if(lc($codigoEncuesta) eq lc($filtro) || lc($codigoEncuesta) =~ /$filtro/){
			return 1;
		}
	}

	return 0;
}

# necesita de $filtroSeleccionModalidad
# recibe $modalidad
sub esModalidadSeleccionada{
	DEBUG "@filtroSeleccionModalidad \n";
	
	# si el array tiene el valor default, salgo inmediatamente contestando true al matching
	if($filtroSeleccionModalidad[0] eq "*"){
		return 1;
	}
	
	$modalidad = $_[0];

	foreach $filtro (@filtroSeleccionModalidad){	
		if(lc($modalidad) eq lc($filtro) || lc($modalidad) =~ /$filtro/){
			return 1;
		}
	}

	return 0;
}

# recibe $encuestador, $nroEncuesta, $codigoEncuesta, $modalidad
sub esEncuestaSeleccionada{
	$encuestador=$_[0];
	$nroEncuesta=$_[1];
	$codigoEncuesta=$_[2];
	$modalidad=$_[3];

	if(esEncuestadorSeleccionado($encuestador) && esNroEncuestaSeleccionada($nroEncuesta) && esCodigoEncuestaSeleccionado($codigoEncuesta) && esModalidadSeleccionada($modalidad)){
		return 1;
	}else{
		return 0;
	}
}

# necesita $encuestasSeleccionadas{}
# recibe $codigoEncuesta, $puntajeObtenido
sub obtenerColorPuntaje{
	use Switch;

	$codigoEncuesta = $_[0];
	$puntajeObtenido = $_[1];
	$color = "ERROR-color-desconocido";

	# Using 'each' in a 'while' loop
	#  * This method's advantage is that it uses very little memory (every time 'each' is called it only returns a pair of (key, value) element).
	#  * The disadvantage is that you can't order the output by key.
	while ( $key = each %infoEncuestasMaestro ){
		if($key eq $codigoEncuesta){
			DEBUG "key: $key -> $infoEncuestasMaestro{$key}{\"verde-inicial\"}\n";

			switch($puntajeObtenido){
				case[$infoEncuestasMaestro{$key}{"verde-inicial"} .. $infoEncuestasMaestro{$key}{"verde-final"}]{
					DEBUG "Para la encuesta $codigoEncuesta, el puntaje obtenido ($puntajeObtenido) corresponde al color verde!\n";
					$color = "verde";
				}

				case[$infoEncuestasMaestro{$key}{"amarillo-inicial"} .. $infoEncuestasMaestro{$key}{"amarillo-final"}]{
					DEBUG "Para la encuesta $codigoEncuesta, el puntaje obtenido ($puntajeObtenido) corresponde al color amarillo!\n";
					$color = "amarillo";
				}

				case[$infoEncuestasMaestro{$key}{"rojo-inicial"} .. $infoEncuestasMaestro{$key}{"rojo-final"}]{
					DEBUG "Para la encuesta $codigoEncuesta, el puntaje obtenido ($puntajeObtenido) corresponde al color rojo!\n";
					$color = "rojo";
				}
				
				else{
					MOSTRAR_ERROR "Para la encuesta $codigoEncuesta, el puntaje $puntajeObtenido NO corresponde a ningún color!\n";
					exit 1;
				}
			}
		}
	}	
	
	return $color;
}

# recibe $encuestador, $codigoEncuesta
sub obtenerGrupoDeOrdenamiento{
	use Switch;
	
	$encuestador = $_[0];
	$codigoEncuesta = $_[1];
	
	$grupoDeOrdenamiento = "";
	
	switch($agrupamiento){
		case ("x-cod"){
			$grupoDeOrdenamiento = $codigoEncuesta;
		}
		
		case ("x-enc"){
			$grupoDeOrdenamiento = $encuestador;
		}
		
		case ("*"){
			$grupoDeOrdenamiento = $encuestador . "." . $codigoEncuesta;
		}
		
		else{
			MOSTRAR_ERROR("El modo de agrupamiento $agrupamiento es inválido.\n");
			exit 1;
		}
	}
	
	DEBUG "grupo encuesta-encuestador?: $grupoDeOrdenamiento";
	return $grupoDeOrdenamiento;
}

#necesita $encuestasSeleccionadas{}{}
#recibe $encuestador, $codigoEncuesta, $puntajeObtenido
sub agregarEncuesta{
	$encuestador = $_[0];
	$codigoEncuesta = $_[1];
	$puntajeObtenido = $_[2];
	
	$grupoDeOrdenamiento = obtenerGrupoDeOrdenamiento($encuestador, $codigoEncuesta);
	
	$encuestasSeleccionadas{$grupoDeOrdenamiento}{obtenerColorPuntaje($codigoEncuesta, $puntajeObtenido)} += 1;
	DEBUG "$encuestasSeleccionadas{$grupoDeOrdenamiento}{obtenerColorPuntaje($codigoEncuesta, $puntajeObtenido)} \n";
}

# escribe $encuestasSeleccionadas{}
# necesita %infoEncuestadoresMaestro{}{}
# recibe $encuestador, $fechaEncuesta, $nroEncuesta, $codigoEncuesta, $puntajeObtenido, $codCliente, $sitioRelevamiento, $modalidad, $personaRelevada
sub agregarEncuestaEspecifica{
	#
	# 12.Otra consulta puede estar dada por un nro de encuesta específico.
	#    En este caso lo que se debe mostrar son todos los detalles del registro,
	#    en formato amigable y con las leyendas correspondientes nombre del encuestador,
	#    nombre de la encuesta, cantidad de preguntas y a continuación del puntaje
	#    obtenido, indicar el color que le corresponde.
	#
	# Encuesta Nro: xxx realizada por <userid> + <nombre> el dia xxx
	# Cliente ccc, Modalidad x, sitio y, persona z
	# Encuesta Aplicada: <código y nombre de la encuesta> compuesta por n preguntas
	# Puntaje obtenido: nnn calificación: <color>
	#

	$encuestador = $_[0];
	$fechaEncuesta = $_[1];
	$nroEncuesta = $_[2];
	$codigoEncuesta = $_[3];
	$puntajeObtenido = $_[4];
	$codCliente = $_[5];
	$sitioRelevamiento = $_[6];
	$modalidad = $_[7];
	$personaRelevada = $_[8];
	
	$stringReporte = "Encuesta Nro: " . $nroEncuesta . ", realizada por " . $encuestador . "-\"" . $infoEncuestadoresMaestro{$encuestador}{"nombre"} . "\" el dia " . $fechaEncuesta . "\n"
	               . "Cliente " . $codCliente . ", Modalidad " . $modalidad . ", sitio " . $sitioRelevamiento . ", persona " . $personaRelevada . "\n"
	               . "Encuesta Aplicada: " . $codigoEncuesta . "-\"" . $infoEncuestasMaestro{$codigoEncuesta}{"nombre"} . "\" compuesta por " . $infoEncuestasMaestro{$codigoEncuesta}{"cantidad-preguntas"} . " preguntas" . "\n"
	               . "Puntaje obtenido: " . $puntajeObtenido . ", calificación: " . obtenerColorPuntaje($codigoEncuesta, $puntajeObtenido) . "\n";
	
	$encuestasSeleccionadas{"encuesta-específica"}{"string-reporte"} = $stringReporte;
}

# necesita %infoEncuestasMaestro{}{}
# recibe $pathYNombreArchivo
sub obtenerInfoEncuestasMaestras{
	#
	# Formato del archivo maestro: $grupo/mae/encuestas.mae
	#
	#    Campo                  | Descripción
	# ----------------------------------------
	# 1. Código de encuesta     | 3 caracteres
	# 2. Nombre de la encuesta  | N caracteres
	# 3. Cantidad de preguntas  | numérico 
	# 4. Verde-Rango Inicial    | numérico 
	# 5. Verde-Rango Final      | numérico 
	# 6. Amarillo-Rango Inicial | numérico 
	# 7. Amarillo-Rango Final   | numérico 
	# 8. Rojo-Rango Inicial     | numérico 
	# 9. Rojo-Rango Final       | numérico 
	#
	# Separador de campos: , coma.
	#
	# Ejemplos:
	#  E01, Estándar para nuevos clientes,9,20,999,10,19,-999,9
	#  E02, Satisfacción de clientes,7,55,999,35,54,-999,34
	#  E03, Cambio de categoria,3,12,999,8,11,-999,7
	#  E04, Búsqueda de prospectos,12,120,999,88,119,-999,87
	#  E05, Calificación de oportunidades,5,50,999,30,49,-999,29
	#
	
	$pathYNombreArchivo = $_[0];
	
	if(open (FILE_HANDLER, $pathYNombreArchivo)){
		while (<FILE_HANDLER>) {
			chomp; # quito el caracter de corte de linea al final de linea

			($codigoEncuesta, $nombreEncuesta, $cantidadPreguntas, $verde_inicial, $verde_final, $amarillo_inicial, $amarillo_final, $rojo_inicial, $rojo_final)=split(",");
			
			$infoEncuestasMaestro{$codigoEncuesta}{"nombre"}             = $nombreEncuesta;
			$infoEncuestasMaestro{$codigoEncuesta}{"cantidad-preguntas"} = $cantidadPreguntas;
			
			$infoEncuestasMaestro{$codigoEncuesta}{"verde-inicial"}    = $verde_inicial;
			$infoEncuestasMaestro{$codigoEncuesta}{"verde-final"}      = $verde_final; 
			$infoEncuestasMaestro{$codigoEncuesta}{"amarillo-inicial"} = $amarillo_inicial; 
			$infoEncuestasMaestro{$codigoEncuesta}{"amarillo-final"}   = $amarillo_final; 
			$infoEncuestasMaestro{$codigoEncuesta}{"rojo-inicial"}     = $rojo_inicial; 
			$infoEncuestasMaestro{$codigoEncuesta}{"rojo-final"}       = $rojo_final; 
			
			DEBUG(
				$codigoEncuesta.
				" verde[".$infoEncuestasMaestro{$codigoEncuesta}{"verde-inicial"}.     ",".$infoEncuestasMaestro{$codigoEncuesta}{"verde-final"}."]".
				" amarillo[".$infoEncuestasMaestro{$codigoEncuesta}{"amarillo-inicial"}.",".$infoEncuestasMaestro{$codigoEncuesta}{"amarillo-final"}."]".
				" rojo[".$infoEncuestasMaestro{$codigoEncuesta}{"rojo-inicial"}.       ",".$infoEncuestasMaestro{$codigoEncuesta}{"rojo-final"}."]".
				"\n");
		}
		close(FILE_HANDLER);
	}else{
		MOSTRAR_ERROR "No existe el achivo ".$pathYNombreArchivo."\n";
		return 1;
	}

	return 0;
}

# necesita %infoEncuestadoresMaestro{}{}
# recibe $pathYNombreArchivo
sub obtenerInfoEncuestadoresMaestro{
	#
	# Formato del archivo maestro: $grupo/mae/encuestadores.mae
	#
	#    Campo                  | Descripción
	# ----------------------------------------
	# 1. Userid del encuestador | 8 caracteres
	# 2. Nombre del encuestador | N caracteres
	# 3. CUIL                   | 11 numérico 
	# 4. Valido desde           | fecha
	# 5. Valido hasta           | fecha 
	#
	# Separador de campos: , coma
	#
	# Ejemplo: ESTEPANO, Elio Stepano,20216445882,20081212,20110912
	#

	$pathYNombreArchivo = $_[0];
	
	if(open (FILE_HANDLER, $pathYNombreArchivo)){
		while (<FILE_HANDLER>) {
			chomp; # quito el caracter de corte de linea al final de linea

			($userIdEncuestador, $nombreEncuestador, $null, $null, $null)=split(",");
			$infoEncuestadoresMaestro{$userIdEncuestador}{"nombre"} = $nombreEncuestador;
		}
		close(FILE_HANDLER);
	}else{
		MOSTRAR_ERROR "No existe el achivo ".$pathYNombreArchivo."\n";
		return 1;
	}

	return 0;
}

sub seSolicitoEncuestaEspecifica{
	#
	# 12.Otra consulta puede estar dada por un nro de encuesta específico.
	#    En este caso lo que se debe mostrar son todos los detalles del registro,
	#    en formato amigable y con las leyendas correspondientes nombre del encuestador,
	#    nombre de la encuesta, cantidad de preguntas y a continuación del puntaje
	#    obtenido, indicar el color que le corresponde.
	#
	# Encuesta Nro: xxx realizada por <userid> + <nombre> el dia xxx
	# Cliente ccc, Modalidad x, sitio y, persona z
	# Encuesta Aplicada: <código y nombre de la encuesta> compuesta por n preguntas
	# Puntaje obtenido: nnn calificación: <color>
	#

#	use POSIX;# si tiene posix, se puede utilizar isdigit()
#	if(@filtroSeleccionNroEncuesta == 1 && isdigit($filtroSeleccionNroEncuesta[0])){
	if(@filtroSeleccionNroEncuesta == 1 && $filtroSeleccionNroEncuesta[0] =~ /^[+-]?\d+$/){
		return 1;
	}else{
		return 0;
	}
}

sub obtenerInfoEncuestasSumarizadas{
	#
	# Formato del sumario de Encuestas, archivo $grupo/ya/encuestas.sum
	#    Campos                        | Fuente
	# ----------------------------------------------------------------------------------------
	# 1. Encuestador                   | Userid del nombre del archivo de encuestas realizadas
	# 2. Fecha de realización          | Fecha del nombre del archivo de encuestas realizadas
	# 3. Nro. de Encuesta Realizada    | del archivo de encuestas realizadas
	# 4. Código de encuesta            | del archivo de encuestas realizadas
	# 5. Puntaje Obtenido              | Numérico, campo calculado por sumarC
	# 6. Código de cliente o prospecto | del archivo de encuestas realizadas
	# 7. Sitio de Relevamiento         | del archivo de encuestas realizadas
	# 8. Modalidad de encuesta         | del archivo de encuestas realizadas
	# 9. Persona Relevada              | del archivo de encuestas realizadas
	#
	# Separador de campos: , coma
	#
	# Ejemplo: ESTEPANO,20110909,1022,E03,12,30354444882,E,P,II
	#

	$pathYNombreArchivo = $_[0];
	
	if(open (FILE_HANDLER, $pathYNombreArchivo)){
		if(seSolicitoEncuestaEspecifica()){
			while (<FILE_HANDLER>) {
				chomp; # quito el caracter de corte de linea al final de linea
				
				($encuestador, $fechaEncuesta, $nroEncuesta, $codigoEncuesta, $puntajeObtenido, $codCliente, $sitioRelevamiento, $modalidad, $personaRelevada)=split(",");
	
				if($nroEncuesta eq $filtroSeleccionNroEncuesta[0]){
					agregarEncuestaEspecifica($encuestador, $fechaEncuesta, $nroEncuesta, $codigoEncuesta, $puntajeObtenido, $codCliente, $sitioRelevamiento, $modalidad, $personaRelevada);
					return 0;
				}
			}
		}else{
			while (<FILE_HANDLER>) {
				chomp; # quito el caracter de corte de linea al final de linea
	
				($encuestador, $null, $nroEncuesta, $codigoEncuesta, $puntajeObtenido, $null, $null, $modalidad, $null)=split(",");
	
				if(esEncuestaSeleccionada($encuestador, $nroEncuesta, $codigoEncuesta, $modalidad)){
					agregarEncuesta($encuestador, $codigoEncuesta, $puntajeObtenido);
				}
			}
		}
	}else{
		MOSTRAR_ERROR "No existe el achivo ".$pathYNombreArchivo."\n";
		return 1;
	}

	return 0;
}

sub generarIdArchivoResultado{
	
	# TODO: mejorar la forma en la cual garantizo que el id sea siempre único
	
	if(open(FILE_HANDLER_TEST, $pathYNombreArchivoResultados.$idArchivo)){
		close(FILE_HANDLER_TEST);

		# este sleep es para que si lo ejecutan más de una vez por segundo,
		# espere para que cambie el id del archivo y así "garantizar"
		# que siempre retorne un id diferente
		sleep 1;
	}
	
	( $seg, $min, $hs, $dia, $mes, $anio ) = ( localtime ) [ 0, 1, 2, 3, 4, 5 ];
	return sprintf("%4d%02d%02d-%02d%02d%02d", $anio+1900, $mes+1, $dia, $hs, $min, $seg);
}

# necesita $encuestasSeleccionadas{}{}
sub entregarResultados{
	if(seSolicitoEncuestaEspecifica()){
		$stringReporte = "";

		if(defined $encuestasSeleccionadas{"encuesta-específica"}{"string-reporte"}){
			$stringReporte = $encuestasSeleccionadas{"encuesta-específica"}{"string-reporte"};
		}else{
			$stringReporte = "La encuesta número " . $filtroSeleccionNroEncuesta[0] . " no fue encontrada. Argumentos recibidos: " . "@ARGV" . "\n";
		}

		if($mostrarResultadosEnPantalla == 1){
			MOSTRAR_EN_PANTALLA($stringReporte);
		}
	
		$idArchivo = "";
		if($guardarResultadosEnArchivo == 1){
			$idArchivo = generarIdArchivoResultado();
			GUARDAR_EN_ARCHIVO($idArchivo, $stringReporte);
		}
	}else{
		if(keys( %encuestasSeleccionadas ) == 0){
			$stringReporte = "No fue encontrada ninguna encuesta para la selección especificada. Argumentos recibidos: " . "@ARGV" . "\n";
	
			if($mostrarResultadosEnPantalla == 1){
				MOSTRAR_EN_PANTALLA($stringReporte);
			}
		
			$idArchivo = "";
			if($guardarResultadosEnArchivo == 1){
				$idArchivo = generarIdArchivoResultado();
				GUARDAR_EN_ARCHIVO($idArchivo, $stringReporte);
			}
		}else{
			$strSeparadorColumnasResultados = "\t\t\t";
			$stringEncabezadoResultado = "CRITERIO" . $strSeparadorColumnasResultados . "VERDE" . $strSeparadorColumnasResultados . "AMARILLO" . $strSeparadorColumnasResultados . "ROJO" . "\n";
			
			if($mostrarResultadosEnPantalla == 1){
				MOSTRAR_EN_PANTALLA($stringEncabezadoResultado);
			}
		
			$idArchivo = "";
			if($guardarResultadosEnArchivo == 1){
				$idArchivo = generarIdArchivoResultado();
				GUARDAR_EN_ARCHIVO($idArchivo, $stringEncabezadoResultado);
			}
		
			# Using 'keys' in a 'foreach' loop
			#  * This method has the advantage that it's possible to sort the output by key.
			#  * The disadvantage is that it creates a temporary list to hold the keys, in case your hash is very large you end up using lots of memory resources.
			foreach my $key (sort keys %encuestasSeleccionadas){
				
				# Esto es para inicializar en cero
				if($encuestasSeleccionadas{$key}{"verde"}){
					;
				}else{
					$encuestasSeleccionadas{$key}{"verde"} = 0;
				}
				if($encuestasSeleccionadas{$key}{"amarillo"}){
					;
				}else{
					$encuestasSeleccionadas{$key}{"amarillo"} = 0;
				}
				if($encuestasSeleccionadas{$key}{"rojo"}){
					;
				}else{
					$encuestasSeleccionadas{$key}{"rojo"} = 0;
				}
		
				$stringResultado = $key . $strSeparadorColumnasResultados . $encuestasSeleccionadas{$key}{"verde"} . $strSeparadorColumnasResultados . $encuestasSeleccionadas{$key}{"amarillo"} . $strSeparadorColumnasResultados . $encuestasSeleccionadas{$key}{"rojo"} . "\n";
		
				if($mostrarResultadosEnPantalla == 1){
					MOSTRAR_EN_PANTALLA($stringResultado);
				}
		
				if($guardarResultadosEnArchivo == 1){
					GUARDAR_EN_ARCHIVO($idArchivo, $stringResultado);
				}
			}
		}
	}

	return 0;
}

if(procesarArgumentos(@ARGV) != 0){
	exit;
}
if(obtenerInfoEncuestasMaestras($pathYNombreArchivoEncuestasMaestro)){
	exit 1;
}
if(obtenerInfoEncuestadoresMaestro($pathYNombreArchivoEncuestadoresMaestro)){
	exit 1;
}
if(obtenerInfoEncuestasSumarizadas($pathYNombreArchivoEncuestasSumarizadas)){
	exit 1;
}
if(entregarResultados()){
	exit 1;
}

exit 0;
