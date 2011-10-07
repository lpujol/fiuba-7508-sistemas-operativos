#!/usr/bin/perl -w

#
# $Id:$
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
#  -e, --encuestador
#  -c, --código-de-encuesta
#  -n, --nro-de-encuesta
#  -m, --modalidad
#  -h, --help
#
# Valores para los parámetros e, c, m:  1, 2, n, * (todos)
# Valores para el parámetro n:          nro de encuesta, un rango de ellas, * (todos)
#
# En el pasaje de parámetros se puede hacer uso de caracteres comodines (ver GLOSARIO)
#
# Las opciones pueden ser:
#  -c (resuelve la consulta y muestra resultados por pantalla, no graba en archivo)
#  -e (resuelve y emite un informe) o la combinación de ellas
#

#
# Formatos de los archivos maestros
#
# Encuestas: $grupo/mae/encuestas.mae
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


#
# Formato del sumario de Encuestas, archivo $grupo/ya/encuestas.sum
#    Campos                        | Fuente
# ----------------------------------------------------------------------------------------
# 1. Encuestador                   | Userid del nombre del archivo de encuestas realizadas
# 2. Fecha de realización          | Fecha del nombre del archivo de encuestas realizadas
# 3. Nro. de Encuesta Realizada    | del archivo de encuestas realizadas
# 4. Código de encuesta            | del archivo de encuestas realizadas
# 5. Puntaje Obtenido              | Numérico, Campo calculado en este proceso
# 6. Código de cliente o prospecto | del archivo de encuestas realizadas
# 7. Sitio de Relevamiento         | del archivo de encuestas realizadas
# 8. Modalidad de encuesta         | del archivo de encuestas realizadas
# 9. Persona Relevada              | del archivo de encuestas realizadas
#
# Separador de campos: , coma
#
# Ejemplo: ESTEPANO,20110909,1022,E03,12,30354444882,E,P,II
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

#recorro todos los parametros pasados al programa
#selecciono nombres de archivos de beneficiarios
#los guardo en su array correspondiente
#selecciono codigos de beneficio
#los guardo en su array correspondiente
#verifico si se debe imprimir la matriz de controul
print "Parametros: ";
foreach $param (@ARGV) {

	#el primer parametro pasado es
	#el path de recibidos
	if ($path_recibidos eq ""){
		$path_recibidos = $param;
	}
	else
	{
		print "$param\t";
	}

	if($param =~ m/^benef\.[0-9]+$/){
		push(@array_archivos_beneficiarios, $param);
	}

	if($param =~ m/^benerro\.[0-9]+$/){
		push(@array_archivos_benerro, $param);
	}

	if($param =~ m/^[0-9][0-9][0-9][0-9][0-9]$/){
		push(@array_codigos_de_beneficio, $param);
	}

	if($param =~ m/^[a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z][a-zA-Z]$/){
		push(@array_agencias, $param);
	}

	if ($param =~ m/^-c$/){
		$imprimir_matriz_de_control = $param;
	}

	if ($param =~ m/^-ea$/){
		$procesar_aceptados = 1;
	}
	
	if ($param =~ m/^-er$/){
		$procesar_rechazados = 1;
	}
	
	if ($param =~ m/^-ep$/){
		$procesar_pendientes = 1;
	}
	
	if ($param =~ m/^-t$/){
		$salida_por_pantalla = 1;
	}

	if ($param =~ m/^-d$/){
		$salida_por_archivo = 1;
	}

	if (($param =~ m/^-dt$/)||($param =~ m/^-td$/)){
		$salida_por_pantalla = 1;
		$salida_por_archivo = 1;
	}
}
print "\n";

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
	print SEC_OUT "$secuencia\n";
	close(SEC_OUT);

	open (OUT, ">plist".$secuencia) || print "No se pudo crear el archivo de salida\n";
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
		print "El path de archivos postulados es inexistente\n";
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
		open (BENEF, $path_recibidos . $archivo) || print "No existe el achivo ".$path_recibidos."$archivo\n";
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
								print "Beneficio: $codigo_de_beneficio";
								print " Agencia: $agencia";
								print " Cuil: $cuil";
								print " Apellido: $apellido";
								print " Provincia: $provincia";
								print " Estado: $estado";
								print " Fecha efectiva de Alta: $fecha_efectiva_alta\n";
							}
								
							#salida por archivo
							if ($salida_por_archivo){
								print OUT "Beneficio: $codigo_de_beneficio";
								print OUT " Agencia: $agencia";
								print OUT " Cuil: $cuil";
								print OUT " Apellido: $apellido";
								print OUT " Provincia: $provincia";
								print OUT " Estado: $estado";
								print OUT " Fecha efectiva de Alta: $fecha_efectiva_alta\n";
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
		open (BENERRO, $path_recibidos . $archivo) || print "No existe el achivo ".$path_recibidos."$archivo\n";
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
							print "Beneficio: $codigo_de_beneficio";
							print " Agencia: $agencia";
							print " Cuil: $cuil";
							print " Apellido: $apellido";
							print " Provincia: $provincia";
							print " Estado: rechazado";
							print " Fecha pedida de Alta: $fecha_pedida_alta\n";
						}

						#salida por archivo
						if ($salida_por_archivo){
							print OUT "Beneficio: $codigo_de_beneficio";
							print OUT " Agencia: $agencia";
							print OUT " Cuil: $cuil";
							print OUT " Apellido: $apellido";
							print OUT " Provincia: $provincia";
							print OUT " Estado: rechazado";
							print OUT " Fecha pedida de Alta: $fecha_pedida_alta\n";
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
		print "\n";
	}
	if ($salida_por_archivo)
	{
		print OUT "\n";
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
			print "\n";
		}
		if ($salida_por_archivo)
		{
			printf OUT "%-10d",$hash_provincia{$provincia};
			print OUT "\n";
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
		print "\n";
	}
	if ($salida_por_archivo)
	{
		printf OUT "%-10d",$total_postulantes;
		print OUT "\n";

		close(OUT);
	}
}

exit;
