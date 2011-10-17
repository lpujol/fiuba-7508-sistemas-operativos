#!/usr/bin/perl -w

# Estoy en UTF8: sí

#
# $Id$
#

#
# Interacción de este programa con el resto del sistema:
#  Necesita de los archivos:
#   ../ya/encuestas.sum
#   ../mae/encuestas.mae
#   ../mae/preguntas.mae
#   ../mae/encuestadores.mae
#
#  Los informes se graban en el directorio: ../ya
#
#  No escribe logs
#

#
# Los parámetros pueden ser:
#  -enc, --encuestador
#  -cod, --código-de-encuesta
#  -n, --nro-de-encuesta
#  -m, --modalidad
#  -h, --help
#
# Valores posibles para los parámetros enc, cod, m:  1, 2, n, * (todos)
# Valores posibles para el parámetro n:              nro de encuesta, un rango de ellas, * (todos)
# Valores posibles para el parámetro m:              E (electrónica), T (telefónica), C (correo convencional) o P (presencial) y todas sus combinaciones posibles
#
# En el pasaje de parámetros se puede hacer uso de caracteres comodines (ver GLOSARIO)
#
# Las opciones pueden ser:
#  -c (resuelve la consulta y muestra resultados por pantalla, no graba en archivo)
#  -e (resuelve y emite un informe)
# O la combinación de ellas.
#


#
# Variables seteadas a partir de los argumentos recibidos por el programa
                                        # parámetro que lo controla
my $filtroSeleccionEncuestadores = "";  # -enc, --encuestador
my $filtroSeleccionCodigoEncuesta = ""; # -cod, --código-de-encuesta
my $filtroSeleccionNroEncuesta = "";    # -n, --nro-de-encuesta
my $filtroSeleccionModalidad = "";      # -m, --modalidad
my $mostrarResultadosEnPantalla = 1;    # -c (resuelve la consulta y muestra resultados por pantalla, no graba en archivo)
my $guardarResultadosEnArchivo = 1;     # -e (resuelve y emite un informe)


my $agruparEncuestasPorEncuestador = 1; # esto debería poder setearse a través de algún nuevo parámetro del programa


# Hash en el que almacenaré los datos obtenidos del archivo maestro de encuestas
my %infoEncuestasMaestro = ();

# Hash en el que almacenaré las encuestas seleccionadas por los criterios del "query"
my %encuestasSeleccionadas = ();


#
# Variables de "entorno"
my $pathArchivosMaestros = "../mae/";  # = $grupo/mae
my $pathArchivosYa = "../ya/";         # = $grupo/ya
my $pathArchivosResultados = "../ya/"; # = $grupo/ya
my $pathYNombreArchivoEncuestasMaestro = $pathArchivosMaestros."encuestas.mae";
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
	print "Los parámetros pueden ser:\n";
	print " -enc, --encuestador\n";
	print " -cod, --código-de-encuesta\n";
	print " -n, --nro-de-encuesta\n";
	print " -m, --modalidad\n";
	print " -h, --help\n";
	
	print "\n";
	
	print "Valores posibles para los parámetros enc, cod, m:  1, 2, n, * (todos)\n";
	print "Valores posibles para el parámetro n:              nro de encuesta, un rango de ellas, * (todos)\n";
	print "Valores posibles para el parámetro m:              E (electrónica), T (telefónica), C (correo convencional) o P (presencial) y todas sus combinaciones posibles\n";
	
	print "\n";
	
	print "En el pasaje de parámetros se puede hacer uso de caracteres comodines (ver GLOSARIO)\n";
	
	print "\n";
	
	print "Las opciones pueden ser:\n";
	print " -c (resuelve la consulta y muestra resultados por pantalla, no graba en archivo)\n";
	print " -e (resuelve y emite un informe)\n";
	print "O la combinación de ellas.\n";
	
	print "\n";
}

# recibe @ARGV
sub procesarArgumentos{
	use Switch;

	$estado_procesador_de_argumentos = "recibiendo-tipo-parametro";

	DEBUG "Parametros: ";
	
	foreach $param (@_) {
	
	
		switch ($estado_procesador_de_argumentos){
			case("recibiendo-tipo-parametro") {
				switch($param){
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
			
					else{
						DEBUG "ERROR: argumento desconocido!, \$param=$param\n";
						return 1;
					}
				}
			}
	
			case("recibiendo-valor-encuestador"){
				$filtroSeleccionEncuestadores = $param;
				$estado_procesador_de_argumentos = "recibiendo-tipo-parametro";
			}
	
			case("recibiendo-valor-codigo-encuesta"){
				$filtroSeleccionCodigoEncuesta = $param;
				$estado_procesador_de_argumentos = "recibiendo-tipo-parametro";
			}
	
			case("recibiendo-valor-nro-encuesta"){
				$filtroSeleccionNroEncuesta = $param;
				$estado_procesador_de_argumentos = "recibiendo-tipo-parametro";
			}
	
			case("recibiendo-valor-modalidad"){
				$filtroSeleccionModalidad = $param;
				$estado_procesador_de_argumentos = "recibiendo-tipo-parametro";
			}
	
			else{
				MOSTRAR_ERROR "\ERROR: estado desconocido, \$estado_procesador_de_argumentos=$estado_procesador_de_argumentos\n";
				return 1;
			}
		}
	}
	DEBUG "\n";
	
	return 0;
}

# necesita de $filtroSeleccionEncuestadores
# recibe $encuestador
sub esEncuestadorSeleccionado{
	if($filtroSeleccionEncuestadores eq "*"){
		return 1;
	}
	
	$encuestador = $_[0];
	
	if(lc($encuestador) eq lc($filtroSeleccionEncuestadores)){
		return 1;
	}
	
	if($encuestador =~ m/$filtroSeleccionEncuestadores/){
		return 1;
	}else{
		return 0;
	}
}

# necesita de $filtroSeleccionNroEncuesta
# recibe $nroEncuesta
sub esNroEncuestaSeleccionada{
	if($filtroSeleccionNroEncuesta eq "*"){
		return 1;
	}
	
	$nroEncuesta = $_[0];
	
	if($nroEncuesta =~ m/$filtroSeleccionNroEncuesta/){
		return 1;
	}else{
		return 0;
	}
}

# necesita de $filtroSeleccionCodigoEncuesta
# recibe $codigoEncuesta
sub esCodigoEncuestaSeleccionado{
	if($filtroSeleccionCodigoEncuesta eq "*"){
		return 1;
	}
	
	$codigoEncuesta = $_[0];
	
	if($codigoEncuesta =~ m/$filtroSeleccionCodigoEncuesta/){
		return 1;
	}else{
		return 0;
	}
}

# necesita de $filtroSeleccionModalidad
# recibe $modalidad
sub esModalidadSeleccionada{
	if($filtroSeleccionModalidad eq "*"){
		return 1;
	}
	
	$modalidad = $_[0];
	
	if($modalidad =~ m/$filtroSeleccionModalidad/){
		return 1;
	}else{
		return 0;
	}
}

# recibe $encuestador, $nroEncuesta, $codigoEncuesta, $modalidad
sub esEncuestaSeleccionada{
	$encuestador=$_[0];
	$nroEncuesta=$_[1];
	$codigoEncuesta=$_[2];
	$modalidad=$_[3];
	
	if(esEncuestadorSeleccionado($encuestador) || esNroEncuestaSeleccionada($nroEncuesta) || esCodigoEncuestaSeleccionado($codigoEncuesta) || esModalidadSeleccionada($modalidad)){
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


	# Using 'keys' in a 'foreach' loop
	#  * This method has the advantage that it's possible to sort the output by key.
	#  * The disadvantage is that it creates a temporary list to hold the keys, in case your hash is very large you end up using lots of memory resources.
	# foreach my $key ( keys %infoEncuestasMaestro ){

	# Using 'each' in a 'while' loop
	#  * This method's advantage is that it uses very little memory (every time 'each' is called it only returns a pair of (key, value) element).
	#  * The disadvantage is that you can't order the output by key.
	# while ( $key = each %infoEncuestasMaestro )

	
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

#necesita $encuestasSeleccionadas{}{}
#recibe $encuestador, $codigoEncuesta, $puntajeObtenido
sub agregarEncuesta{
	$encuestador = $_[0];
	$codigoEncuesta = $_[1];
	$puntajeObtenido = $_[2];
	
	$grupo = $codigoEncuesta;
	
	if($agruparEncuestasPorEncuestador == 1){
		$grupo .= ("." . $encuestador);
	}
	DEBUG "grupo encuesta-encuestador?: $grupo";

	$encuestasSeleccionadas{$grupo}{obtenerColorPuntaje($codigoEncuesta, $puntajeObtenido)} += 1;
	DEBUG "$encuestasSeleccionadas{$grupo}{obtenerColorPuntaje($codigoEncuesta, $puntajeObtenido)} \n";
}

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

			($codigoEncuesta, $null, $null, $verde_inicial, $verde_final, $amarillo_inicial, $amarillo_final, $rojo_inicial, $rojo_final)=split(",");
			
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

sub obtenerEncuestadores{
	#
	# Encuestadores: $grupo/mae/encuestadores.mae
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
		while (<FILE_HANDLER>) {
			chomp; # quito el caracter de corte de linea al final de linea
			
			($encuestador, $null, $nroEncuesta, $codigoEncuesta, $puntajeObtenido, $null, $null, $modalidad, $null)=split(",");
			if(esEncuestaSeleccionada($encuestador, $nroEncuesta, $codigoEncuesta, $modalidad)){
				agregarEncuesta($encuestador, $codigoEncuesta, $puntajeObtenido);
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
	# este sleep es para garantizar que siempre retorne un id diferente
	sleep 1;
	
	( $seg, $min, $hs, $dia, $mes, $anio ) = ( localtime ) [ 0, 1, 2, 3, 4, 5 ];
	return sprintf("%4d%02d%02d-%02d%02d%02d", $anio+1900, $mes+1, $dia, $hs, $min, $seg);
}

# necesita $encuestasSeleccionadas{}{}
sub entregarResultados{
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

	return 0;
}

if(procesarArgumentos(@ARGV) != 0){
	exit;
}
if(obtenerInfoEncuestasMaestras($pathYNombreArchivoEncuestasMaestro)){
	exit;
}
if(obtenerInfoEncuestasSumarizadas($pathYNombreArchivoEncuestasSumarizadas)){
	exit;
}
if(entregarResultados()){
	exit;
}

exit;
