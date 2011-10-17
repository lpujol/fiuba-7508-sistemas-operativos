#!/usr/bin/perl -w

#
# $Id$
#

#
# Interacción de este programa con el resto del sistema:
#  Necesita de los archivos:
#   $grupo/ya/encuestas.sum
#   $grupo/mae/encuestas.mae
#   $grupo/mae/preguntas.mae
#   $grupo/mae/encuestadores.mae
#
#  Los informes se graban en el directorio: $grupo/ya
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
# Formatos de los archivos maestros
#
# Preguntas: $grupo/mae/preguntas.mae
#   Campo            | Descripción o valor
# ---------------------------------------------------------------
# 1. Id de Pregunta   | Numérico
# 2. Pregunta         | N caracteres
# 3. Tipo de Pregunta | Valores posibles: + (positiva), - (negativa)
# 4. Ponderación      | Valores posibles: ALTA, MEDIA, BAJA
#
# Separador de campos: , coma.
#
# Ejemplos:
#  110, Posee Numero de CUIT,+,ALTA
#  111, Quiere contratar servicios premium,+,ALTA
#  120, Tiene domicilio en capital,+,MEDIA
#  121, Quiere contratar servicios estandard,+,MEDIA
#  130, Es un referido,+,BAJA
#  131, Usa habitualmente el debito automatico,+,BAJA
#  210, Tiene deuda atrasada en mas de 3 meses,-,ALTA
#  211, Tiene acción judicial pendiente,-,ALTA
#  220, Cambia regularmente de proveedor,-,MEDIA
#  221, No posee referencias,-,MEDIA
#  230, Está buscando dar de baja servicios,-,BAJA
#  231, Esta en el límite del area de cobertura,-,BAJA
#







#http://www.rocketaware.com/perl/perlfaq4/How_can_I_tell_whether_an_array_.htm
#http://www.tizag.com/perlT/perlarrays.php

my %hash_provincia_y_codigo_de_beneficio = ();
my %hash_provincia = ();
my %hash_codigo_de_beneficio = ();

my $total_postulantes = 0;
my $imprimir_matriz_de_control = 0; #false por default
my $salida_por_pantalla = 0; 
my $salida_por_archivo = 0; 
my $procesar_aceptados = 0; 
my $procesar_rechazados = 0; 
my $procesar_pendientes = 0; 
my $path_recibidos = "";
my $secuencia = 0;

my @array_archivos_beneficiarios;
my @array_archivos_benerro;
my @array_codigos_de_beneficio;
my @array_agencias;



#
# Variables seteadas a partir de los argumentos recibidos por el programa
#
                                        # parámetro que lo controla
my $filtroSeleccionEncuestadores = "";  # -enc, --encuestador
my $filtroSeleccionCodigoEncuesta = ""; # -cod, --código-de-encuesta
my $filtroSeleccionNroEncuesta = "";    # -n, --nro-de-encuesta
my $filtroSeleccionModalidad = "";      # -m, --modalidad
my $mostrarResultadosEnPantalla = 1;    # -c (resuelve la consulta y muestra resultados por pantalla, no graba en archivo)
my $guardarResultadosEnArchivo = 0;     # -e (resuelve y emite un informe)


my $agruparEncuestasPorEncuestador = 1; # esto deberpoder setearse a trav고de alg򮠮uevo par⮥tro del programa


# Hash en el que almacenaré los datos obtenidos del archivo maestro de encuestas
my %infoEncuestasMaestro = ();


# Hash en el que almacenaré las encuestas seleccionadas
my %encuestasSeleccionadas = ();


#
# Variables de entorno
my $pathArchivosMaestros = "./"; # = $grupo/mae
my $pathArchivosYa = "./";       # = $grupo/ya
my $pathYNombreArchivoEncuestasMaestro = $pathArchivosMaestros."encuestas.mae";
my $pathYNombreArchivoEncuestasSumarizadas = $pathArchivosYa."encuestas.sum";



#
# Funciones
#
sub DEBUG{
	print @_;
}

sub MOSTRAR_EN_PANTALLA{
	DEBUG @_;
}

sub mostrarAyuda{
	print "...mostrando la ayuda...";
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
				$codigoEncuesta = $param;
				$estado_procesador_de_argumentos = "recibiendo-tipo-parametro";
			}
	
			case("recibiendo-valor-nro-encuesta"){
				$nroEncuesta = $param;
				$estado_procesador_de_argumentos = "recibiendo-tipo-parametro";
			}
	
			case("recibiendo-valor-modalidad"){
				$modalidad = $param;
				$estado_procesador_de_argumentos = "recibiendo-tipo-parametro";
			}
	
			else{
				DEBUG "\ERROR: estado desconocido, \$estado_procesador_de_argumentos=$estado_procesador_de_argumentos\n";
				return 1;
			}
		}
			
	#	if($param =~ m/^benef\.[0-9]+$/){
	#		push(@array_archivos_beneficiarios, $param);
	#	}
	
	}
	DEBUG "\n";
	
	return 0;
}

# necesita de $filtroSeleccionEncuestadores
#recibe $encuestador
sub esEncuestadorSeleccionado{
	if($filtroSeleccionEncuestadores eq "*"){
		return 1;
	}
	
	$encuestador = $_[0];
	
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
# recibe $nroEncuesta
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
	
	foreach my $key ( keys %infoEncuestasMaestro ){
		if($key eq $codigoEncuesta){
			#DEBUG "key: $key, value: $infoEncuestasMaestro{$key}{\"verde-inicial\"}\n";

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
					DEBUG "Para la encuesta $codigoEncuesta, el puntaje $puntajeObtenido NO corresponde a ningún color!\n";
					exit 1;
				}
			}
		}
	}	
	
	return $color;
}

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

#	if(!%$encuestasSeleccionadas{$grupo}{obtenerColorPuntaje($codigoEncuesta, $puntajeObtenido)}){
#DEBUG "alooo";
#		$encuestasSeleccionadas{$grupo}{obtenerColorPuntaje($codigoEncuesta, $puntajeObtenido)} = 0;
#	}


# FLATA INICIALIZAR $encuestasSeleccionadas{$grupo}{obtenerColorPuntaje($codigoEncuesta, $puntajeObtenido)} en cero!
#DEBUG "$encuestasSeleccionadas{$grupo}{obtenerColorPuntaje($codigoEncuesta, $puntajeObtenido)} \n";
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
		DEBUG "No existe el achivo ".$pathYNombreArchivo."\n";
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
DEBUG $encuestador;
			if(esEncuestaSeleccionada($encuestador, $nroEncuesta, $codigoEncuesta, $modalidad)){
				agregarEncuesta($encuestador, $codigoEncuesta, $puntajeObtenido);
DEBUG $encuestador;
			}
		}
	}else{
		DEBUG "No existe el achivo ".$pathYNombreArchivo."\n";
		return 1;
	}

	return 0;
}

# necesita $encuestasSeleccionadas
sub entregarResultados{
	
	{# iterar el hash $encuestasSeleccionadas

		$stringAMostrar = "fila resultados";
		
		if($mostrarResultadosEnPantalla == 1){
			MOSTRAR_EN_PANTALLA($stringAMostrar);
		}
		
		if($guardarResultadosEnArchivo == 1){
			GUARDAR_EN_ARCHIVO($stringAMostrar);
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





if (($salida_por_pantalla == 0)&&($salida_por_archivo == 0)){
	$salida_por_pantalla = 1; 
}

if (($procesar_aceptados == 0)&&($procesar_rechazados == 0)&&($procesar_pendientes == 0)){
	$procesar_aceptados = 1; 
	$procesar_rechazados = 1; 
	$procesar_pendientes = 1; 
}

if ($salida_por_archivo){
	open (SEC_IN,"<plist.secuencia");
	while (<SEC_IN>){
		chomp;
		$secuencia = $_;
	}
	close(SEC_IN);

	$secuencia = $secuencia + 1;

	open (SEC_OUT,">plist.secuencia");
	DEBUG SEC_OUT "$secuencia\n";
	close(SEC_OUT);

	open (OUT, ">plist".$secuencia) || DEBUG "No se pudo crear el archivo de salida\n";
}

#checkeo si el usuario a ingresado archivos
#sino tomo todos los archivos del directorio
#que tengan el patron benef.* o el patron benerro.*
if((!(@array_archivos_beneficiarios))&&(!(@array_archivos_benerro))){
	if (-d $path_recibidos){
		opendir(DIR,$path_recibidos);
		@aux=readdir(DIR);
		foreach $posible_archivo (@aux){
			if($posible_archivo =~ m/^benef\.[0-9]+$/){
				push(@array_archivos_beneficiarios, $posible_archivo);
			}
			
			if($posible_archivo =~ m/^benerro\.[0-9]+$/){
				push(@array_archivos_benerro, $posible_archivo);
			}
		}
		closedir(DIR);
	}
	else{
		DEBUG "El path de archivos postulados es inexistente\n";
	}
}


#preparo las consultas sobre agencias
undef %es_agencia_solicitada;
for (@array_agencias) { $es_agencia_solicitada{$_} = 1 }

#preparo las consultas sobre beneficios
undef %es_codigo_de_beneficio_solicitado;
for (@array_codigos_de_beneficio) { $es_codigo_de_beneficio_solicitado{$_} = 1 }

if (($procesar_aceptados)||($procesar_pendientes)){
	foreach $archivo (@array_archivos_beneficiarios){
		open (BENEF, $path_recibidos . $archivo) || DEBUG "No existe el achivo ".$path_recibidos."$archivo\n";
		while (<BENEF>) {
				chomp; # quito el caracter de corte de linea al final de linea

				($agencia, $null, $codigo_de_beneficio, $cuil, $null, $null, $apellido, $null, $null, $null, $provincia, $null, $fecha_efectiva_alta, $null, $null, $estado, $null, $null, $null)=split(",");

				#ver si cumple las condiciones para procesar
				if (((lc($estado) eq "aceptado")&&($procesar_aceptados))||((lc($estado) eq "pendiente")&&($procesar_pendientes))){
					#si el hash esta vacio, no se dieron restricciones sobre agencias
					if (($es_agencia_solicitada{$agencia}) || (!%es_agencia_solicitada)){
						#si el hash esta vacio, no se dieron restricciones sobre codigos de beneficio
						if (($es_codigo_de_beneficio_solicitado{$codigo_de_beneficio}) || ((!%es_codigo_de_beneficio_solicitado))){
					
							$hash_provincia_y_codigo_de_beneficio{$provincia}{$codigo_de_beneficio} +=1;
							$hash_provincia{$provincia} +=1;
							$hash_codigo_de_beneficio{$codigo_de_beneficio} +=1;
							$total_postulantes +=1;

							#salida por pantalla
							if ($salida_por_pantalla){
								DEBUG "Beneficio: $codigo_de_beneficio";
								DEBUG " Agencia: $agencia";
								DEBUG " Cuil: $cuil";
								DEBUG " Apellido: $apellido";
								DEBUG " Provincia: $provincia";
								DEBUG " Estado: $estado";
								DEBUG " Fecha efectiva de Alta: $fecha_efectiva_alta\n";
							}
								
							#salida por archivo
							if ($salida_por_archivo){
								DEBUG OUT "Beneficio: $codigo_de_beneficio";
								DEBUG OUT " Agencia: $agencia";
								DEBUG OUT " Cuil: $cuil";
								DEBUG OUT " Apellido: $apellido";
								DEBUG OUT " Provincia: $provincia";
								DEBUG OUT " Estado: $estado";
								DEBUG OUT " Fecha efectiva de Alta: $fecha_efectiva_alta\n";
							}
						}
					}
				}
			}

		close(BENEF);
	}
}


if ($procesar_rechazados){
	foreach $archivo (@array_archivos_benerro){
		open (BENERRO, $path_recibidos . $archivo) || DEBUG "No existe el achivo ".$path_recibidos."$archivo\n";
		while (<BENERRO>) {
				chomp; # quito el caracter de corte de linea al final de linea

				($agencia, $null, $null, $null, $codigo_de_beneficio, $cuil, $null, $null, $apellido, $null, $null, $null, $provincia, $fecha_pedida_alta, $null)=split(",");

				#si el hash esta vacio, no se dieron restricciones sobre agencias
				if (($es_agencia_solicitada{$agencia}) || (!%es_agencia_solicitada)){
					#si el hash esta vacio, no se dieron restricciones sobre codigos de beneficio
					if (($es_codigo_de_beneficio_solicitado{$codigo_de_beneficio}) || ((!%es_codigo_de_beneficio_solicitado))){
				
						$hash_provincia_y_codigo_de_beneficio{$provincia}{$codigo_de_beneficio} +=1;
						$hash_provincia{$provincia} +=1;
						$hash_codigo_de_beneficio{$codigo_de_beneficio} +=1;
						$total_postulantes +=1;

						#salida por pantalla
						if ($salida_por_pantalla){
							DEBUG "Beneficio: $codigo_de_beneficio";
							DEBUG " Agencia: $agencia";
							DEBUG " Cuil: $cuil";
							DEBUG " Apellido: $apellido";
							DEBUG " Provincia: $provincia";
							DEBUG " Estado: rechazado";
							DEBUG " Fecha pedida de Alta: $fecha_pedida_alta\n";
						}

						#salida por archivo
						if ($salida_por_archivo){
							DEBUG OUT "Beneficio: $codigo_de_beneficio";
							DEBUG OUT " Agencia: $agencia";
							DEBUG OUT " Cuil: $cuil";
							DEBUG OUT " Apellido: $apellido";
							DEBUG OUT " Provincia: $provincia";
							DEBUG OUT " Estado: rechazado";
							DEBUG OUT " Fecha pedida de Alta: $fecha_pedida_alta\n";
						}
					}
				}
			
			}

		close(BENERRO);
	}
}

if (($imprimir_matriz_de_control)&&($total_postulantes)){
	#imprimo encabezado de la matriz
	if ($salida_por_pantalla){
		printf ("%-20s","Codigos");
	}
	if ($salida_por_archivo)
	{
		printf OUT "%-20s","Codigos";
	}

	foreach my $codigo (sort {lc($a) cmp lc($b)} keys %hash_codigo_de_beneficio){
		if ($salida_por_pantalla){
			printf ("%-10s",$codigo);
		}
		if ($salida_por_archivo)
		{
			printf OUT "%-10s",$codigo;
		}
	}
	if ($salida_por_pantalla){
		DEBUG "\n";
	}
	if ($salida_por_archivo)
	{
		DEBUG OUT "\n";
	}
	

	foreach my $provincia (sort {lc($a) cmp lc($b)} keys %hash_provincia_y_codigo_de_beneficio){
		if ($salida_por_pantalla){
			printf ("%-20s",$provincia);
		}
		if ($salida_por_archivo)
		{
			printf OUT "%-20s",$provincia;
		}
		foreach my $codigo (sort {lc($a) cmp lc($b)} keys %hash_codigo_de_beneficio){
			if (exists $hash_provincia_y_codigo_de_beneficio{$provincia}{$codigo}){
				if ($salida_por_pantalla){
					printf ("%-10d",$hash_provincia_y_codigo_de_beneficio{$provincia}{$codigo});
				}
				if ($salida_por_archivo)
				{
					printf OUT "%-10d",$hash_provincia_y_codigo_de_beneficio{$provincia}{$codigo};
				}
			}
			else
			{
				if ($salida_por_pantalla){
					printf ("%-10d","0");
				}
				if ($salida_por_archivo)
				{
					printf OUT "%-10d","0";
				}
			}
		}
		if ($salida_por_pantalla){
			printf ("%-10d",$hash_provincia{$provincia});
			DEBUG "\n";
		}
		if ($salida_por_archivo)
		{
			printf OUT "%-10d",$hash_provincia{$provincia};
			DEBUG OUT "\n";
		}
	}

	if ($salida_por_pantalla){
		printf ("%-20s","");
	}
	if ($salida_por_archivo)
	{
		printf OUT "%-20s","";
	}
	
	foreach my $codigo (sort {lc($a) cmp lc($b)} keys %hash_codigo_de_beneficio){
		if ($salida_por_pantalla){
			printf ("%-10d",$hash_codigo_de_beneficio{$codigo});
		}
		if ($salida_por_archivo)
		{
			printf OUT "%-10d",$hash_codigo_de_beneficio{$codigo};
		}
	}
	if ($salida_por_pantalla){
		printf ("%-10d",$total_postulantes);
		DEBUG "\n";
	}
	if ($salida_por_archivo)
	{
		printf OUT "%-10d",$total_postulantes;
		DEBUG OUT "\n";

		close(OUT);
	}
}

exit;
