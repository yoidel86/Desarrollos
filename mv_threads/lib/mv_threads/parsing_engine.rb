require_relative './parsing_error_type'

# ------------------------------------------------------------------------------------

# information of message type 'P'
MSG_P_KEY = 'P'
MSG_P_SIZE = 134

# maps the p operation types
P_OPERATION_TYPE_MAPPER = {
    # contado
    'CO' => 'CONTADO',

    # oferta publica
    'OP' => 'OFERTA PUBLICA',

    # orden de registro
    'OR' => 'ORDEN DE REGISTRO',

    # sobre asignacion
    'SA' => 'SOBRE ASIGNACION',

    # subscripcion reciproca
    'SR' => 'SUSCRIPCION RECIPROCA',

    # oferta publica de compra
    'OC' => 'OFERTA PUBLICA DE COMPRA',

    # reasignacion
    'RA' => 'REASIGNACION',

    # hechos al cierre
    'HC' => 'HECHOS AL CIERRE',

    # al precio medio
    'XM' => 'Al PRECIO MEDIO'
}

# maps the auction id to it's index
AUCTION_INDEX_MAPPER = {
    # subasta continua/suspencion
    'S' => 'SUBASTA CONTINUA/SUSPENSION',

    # subasta de preapertura
    'P' => 'SUBASTA DE PREAPERTURA',

    # negociacion
    ' ' => 'NEGOCIACION'
}

# maps the short sell indexes
SHORT_SELL_INDEX_MAPPER = {
    '1' => 'CERO PUJA ARRIBA, CUENTA PROPIA',

    '2' => 'CERO PUJA ABAJO, CUENTA PROPIA',

    '3' => 'PUJA ARRIBA, CUENTA PROPIA',

    '4' => 'PUJA ABAJO, CUENTA PROPIA',

    '5' => 'COBERTURA DE TITULOS OPCIONALES',

    '6' => 'CERO PUJA ARRIBA, CUENTA DE TERCEROS',

    '7' => 'CERO PUJA ABAJO, CUENTA DE TERCEROS',

    '8' => 'PUJA ARRIBA CUENTA DE TERCEROS',

    '9' => 'PUJA ABAJO CUENTA DE TERCEROS',

    ' ' => 'NORMAL'
}

# maps the type of concertation
CONCERTATION_TYPE_MAPPER = {
    # operacion de cruce
    'CR' => 'OPERACION DE CRUCE',

    # cierre de ordenes
    'CO' => 'CIERRE DE ORDENES',

    # operacion a precio de cierre
    'HC' => 'OPERACION A PRECIO DE CIERRE',

    # operacion despues del cierre
    'HD' => 'OPERACION DESPUES DEL CIERRE',

    # a precio medio
    'XM' => 'A PRECIO MEDIO',

    # al promedio del dia
    'PD' => 'AL PROMEDIO DEL DIA'
}

# parses a message of type 'P'
def parse_msg_type_p(msg_data)
  # validating the message size
  if msg_data.size() != MSG_P_SIZE
    return [ParsingErrorType::MSG_SIZE_MISMATCH, nil]
  end

  # declaring the structure that will hold the data
  hash = Hash.new()

  # getting the registry type (clave del formato)
  hash['TIPO_REG'] = msg_data[0..1].strip() # 2 bytes

  # getting the transaction
  hash['TRANSACCION'] = (msg_data[2] == 'A') ? 'Alta' : 'Baja' # 1 byte

  # getting the folio (numero de folio-5 digitos-)
  hash['FOLIO'] = msg_data[3..5].to_i() # 5 bytes

  # getting the hour (hora del movimiento-4 dígitos-)
  hash['HORA'] = msg_data[8..11] # 4 bytes

  # getting the tv (4 bytes)
  hash['TV'] = msg_data[12..15].strip() # 4 bytes

  # getting the station (clave de la emisora-nombre de la accion de la empresa-)
  hash['EMISORA'] = msg_data[16..22].strip() # 7 bytes

  # getting the 'serie' (clave de la serie)
  hash['SERIE'] = msg_data[23..27].strip() # 5 bytes

  # getting the volume (volumen)
  hash['VOLUMEN'] = msg_data[28..38].to_i() # 11 bytes

  # getting the instrument price (precio del instrumento)
  hash['PRECIO'] = msg_data[39..50].insert(6, '.').to_f() # 12 bytes

  # getting the rate (no description)
  hash['TASA_PREMIO'] = msg_data[51..55].insert(3, ',').to_f() # 5 bytes

  # getting the days (dias plazo)
  hash['DIAS_PLAZO'] = msg_data[56..58].to_i() # 3 bytes

  # getting the market type (value 'PR')
  hash['TIPO_MERCADO'] = msg_data[59..60] # 2 bytes

  # getting the 'liquidation' (no description)
  hash['LIQUIDACION'] = msg_data[61..62]

  # getting the operation type
  operation_type = msg_data[63..64] # 2 bytes
  hash['TIPO_OPERACION'] = (P_OPERATION_TYPE_MAPPER.has_key?(operation_type)) ? P_OPERATION_TYPE_MAPPER[operation_type] : operation_type

  # getting the auction index
  auction_index = msg_data[65] # 1 byte
  hash['IND_SUBASTA'] = (AUCTION_INDEX_MAPPER.has_key?(auction_index)) ? AUCTION_INDEX_MAPPER[auction_index] : auction_index

  # getting the filler
  hash['FILLER'] = msg_data[66] # 1 byte

  # getting the peak (pico lote)
  hash['PICO_LOTE'] = (msg_data[67] == 'P') ? 'NO FIJA PRECIO' : 'ES LOTE' # 1 byte

  # getting the buy (casa que compra)
  hash['COMPRA'] = msg_data[68..72] # 5 bytes

  # getting the sell (casa que vende)
  hash['VENDE'] = msg_data[73..77] # 5 bytes

  # getting the cupon
  hash['CUPON'] = msg_data[78..81].to_i() # 4 bytes

  # getting the amount (el importe)
  hash['IMPORTE'] = msg_data[82..99].insert(13, '.').to_f() # 18 bytes

  # getting the 'ind-venta-en-corto'
  sale_index = msg_data[100] # 1 byte
  hash['IND_VENTA_EN_CORTO'] = (SHORT_SELL_INDEX_MAPPER.has_key?(sale_index)) ? SHORT_SELL_INDEX_MAPPER[sale_index] : sale_index

  # getting the fact (el hecho) [and inserting the ':' separator]
  hash['HORA_DEL_HECHO'] = msg_data[101..108] # 8 bytes

  # getting the folio cb buy (folio cb compra)
  hash['FOLIO_CB_COMPRA'] = msg_data[109..114] # 6 bytes

  # getting the suffix cb buy (sufijo cb compra)
  hash['SUBFIJO_CB_COMPRA'] = msg_data[115..116] # 2 bytes

  # getting the folio cb sell (folio cb vende)
  hash['FOLIO_CB_VENDE'] = msg_data[117..122] # 6 bytes

  # getting the suffix cb sell (sufijo cb vende)
  hash['SUBFIJO_CB_VENDE'] = msg_data[123..124] # 2 bytes

  # getting the concertation type
  concertation_type = msg_data[125..126] # 2 bytes
  hash['TIPO_CONCERTACION'] = (CONCERTATION_TYPE_MAPPER.has_key?(concertation_type)) ? CONCERTATION_TYPE_MAPPER[concertation_type] : concertation_type

  # getting the folio-7
  hash['FOLIO_7'] = msg_data[127..133].to_i()

  # printing parsed information
  # puts hash
  # hash.to_s()[1..-2].split(',').each { |item| puts item }

  # returning no parsing error and the parsed hash
  return [ParsingErrorType::NO_ERROR, hash]
end

# ------------------------------------------------------------------------------------

# information of message type 'E'
MSG_E_KEY = 'E'
MSG_E_SIZE = 183

# maps the e operation types
E_OPERATION_TYPE_MAPPER = {
    # contado
    'CO' => 'CONTADO',

    # oferta publica
    'OP' => 'OFERTA PUBLICA',

    # operacion de registro
    'OR' => 'OPERACION DE REGISTRO',

    # oferta publica de compra
    'OC' => 'OFERTA PUBLICA DE COMPRA',

    # sobreasignacion
    'SA' => 'SOBREASIGNACION',

    # suscripcion reciproca
    'SR' => 'SUSCRIPCION RECIPROCA',

    # reasignacion
    'RA' => 'REASIGNACION'
}

# maps the trend type
TREND_TYPE_MAPPER = {
    # alza
    'A' => 'ALZA',

    # baja
    'B' => 'BAJA',

    # sin cambio
    'S' => 'SIN CAMBIO'
}

# maps the reference type
REFERENCE_TYPE_MAPPER = {
    # valor nominal actualizado
    'VA' => 'VALOR NOMINAL ACTUALIZADO',

    # ajuste por derechos
    'AJ' => 'AJUSTE-POR-DERECHOS',

    # precio anterior
    'AN' => 'PRECIO-ANTERIOR',

    # nueva serie
    '  ' => 'NUEVA-SERIE'
}

# parses a message of type 'E'
def parse_msg_type_e(msg_data)
  # validating the message size
  if msg_data.size() != MSG_E_SIZE
    return [ParsingErrorType::MSG_SIZE_MISMATCH, nil]
  end

  # declaring the structure that will hold the data
  hash = Hash.new()

  # getting the registry type (tipo del registro)
  hash['TIPO_REG'] = msg_data[0..1].strip() # 2 bytes

  # getting the tv (sin comentarios)
  hash['TV'] = msg_data[2..5].strip() # 4 bytes

  # getting the 'emisora'
  hash['EMISORA'] = msg_data[6..12].strip() # 7 bytes

  # getting the 'serie'
  hash['SERIE'] = msg_data[13..17].strip() # 5 bytes

  # getting the operation type
  operation_type = msg_data[18..19] # 2 bytes
  hash['TIPO_OPERACION'] = (E_OPERATION_TYPE_MAPPER.has_key?(operation_type)) ? E_OPERATION_TYPE_MAPPER[operation_type] : operation_type

  # getting the cupon
  hash['CUPON'] = msg_data[20..23].to_i() # 4 bytes

  # getting the number of operations
  hash['NUMERO_OPERACIONES'] = msg_data[24..27].to_i() # 4 bytes

  # getting the volume
  hash['VOLUMEN'] = msg_data[28..40].to_i() # 13 bytes

  # getting the 'import'
  hash['IMPORTE'] = msg_data[41..58].insert(15, '.').to_f() # 18 bytes

  # getting the 'apertura'
  hash['APERTURA'] = msg_data[59..70].insert(6, '.').to_f() # 12 bytes

  # getting maximum
  hash['MAXIMO'] = msg_data[71..82].insert(6, '.').to_f() # 12 bytes

  # getting minimum
  hash['MINIMO'] = msg_data[83..94].insert(6, '.').to_f() # 12 bytes

  # getting average
  hash['PROMEDIO'] = msg_data[95..106].insert(6, '.').to_f() # 12 bytes

  # getting last
  hash['ULTIMO'] = msg_data[107..118].insert(6, '.').to_f() # 12 bytes

  # getting variation
  hash['VARIACION'] = msg_data[119..130].insert(6, '.').to_f() # 12 bytes

  # getting the trends (tendencia)
  trend_type = msg_data[131]
  hash['TIPO_TENDENCIA'] = (TREND_TYPE_MAPPER.has_key?(trend_type)) ? TREND_TYPE_MAPPER[trend_type] : trend_type

  # getting the percentage
  hash['PORCENTAJE'] = msg_data[132..136].insert(3, '.').to_f() # 5 bytes

  # getting the reference
  reference_type = msg_data[137..138].strip() # 2 bytes
  hash['TIPO_REFERENCIA'] = (REFERENCE_TYPE_MAPPER.has_key?(reference_type)) ? REFERENCE_TYPE_MAPPER[reference_type] : reference_type

  # getting last reference date
  hash['FECHA_ULTIMA_REFERENCIA'] = msg_data[139..146] # 8 bytes

  # getting max price of the last 12 moths
  hash['PRECIO_MAX_ULT_ANNO'] = msg_data[147..158].insert(3, '.').to_f() # 12 bytes

  # getting min price of the last 12 moths
  hash['PRECIO_MIN_ULT_ANNO'] = msg_data[159..170].insert(3, '.').to_f() # 12 bytes

  # getting price of last reference
  hash['PRECIO_ULT_REFERENCIA'] = msg_data[171..182].insert(3, '.').to_f() # 12 bytes

  # printing parsed information
  # puts hash
  # hash.to_s()[1..-2].split(',').each { |item| puts item }

  # returning no parsing error and the parsed hash
  return [ParsingErrorType::NO_ERROR, hash]
end

# ------------------------------------------------------------------------------------

# information of message type 'U'
# MSG_U_KEY = 'U'
# MSG_U_SIZE = 94

## parses a message of type 'U'
#def parse_msg_type_u(sequence_bytes)
#  #MUESTRA ALFA 2
#  muestra = sequence_bytes[2...4]
#
#  case muestra
#    when "RV"
#      hash[:muestra] = "INDICE DE RENTA VARIABLE"
#    when "ME"
#      hash[:muestra] = "INDICE DEL MERCADO (IPC)"
#    when "SI"
#      hash[:muestra] = "INDICE SOCIEDADES DE INVERSION"
#    when "AE"
#      hash[:muestra] = "INDICE ACTIVIDAD ECONOMICA"
#    when "SE"
#      hash[:muestra] = "INDICE SECTORIAL"
#    when "IM"
#      hash[:muestra] = "INDICE MEXICO"
#    when "IT"
#      hash[:muestra] = "INDICE INMEX RT"
#    when "MC"
#      hash[:muestra] = "INDICE MERCADO MEDIANA CAPITALIZACION"
#    when "RT"
#      hash[:muestra] = "INDICE DE RENDIMIENTO TOTAL"
#    when "ID"
#      hash[:muestra] = "INDICE DE DIVIDENDOS"
#    when "IH"
#      hash[:muestra] = "INDICE HABITA"
#    when "HT"
#      hash[:muestra] = "INDICE HABITA RENDIMIENTO TOTAL"
#    when "60"
#      hash[:muestra] = "IPC COMP MX"
#    when "CP"
#      hash[:muestra] = "IPC LARGECAP"
#    when "CG"
#      hash[:muestra] = "IPC MIDCAP"
#    when "CM"
#      hash[:muestra] = "IPC SMALLCAP"
#    when "R6"
#      hash[:muestra] = "IRT COMP MX"
#    when "RP"
#      hash[:muestra] = "IRT LARGECAP"
#    when "RG"
#      hash[:muestra] = "IRT MIDCAP"
#    when "RM"
#      hash[:muestra] = "IRT SMALLCAP"
#    when "MB"
#      hash[:muestra] = "INDICE MEXICO BRAZIL(MeBz)"
#    when "MT"
#      hash[:muestra] = "INDICE MEXICO BRAZIL RENDIMIENTO TOTAL (MeBzRT)"
#    when "BB"
#      hash[:muestra] = "INDICE BRAZIL 15"
#    when "BT"
#      hash[:muestra] = "INDICE BRAZIL 15 RENDIMIENTO TOTAL"
#    when "IZ"
#      hash[:muestra] = "IMEBZ BRASIL"
#    when "IX"
#      hash[:muestra] = "IMEBZ MEXICO"
#    when "XT"
#      hash[:muestra] = "IMEBZ MEXICO RENDIMIENTO TOTAL"
#    when "ZT"
#      hash[:muestra] = "IMEBZ BRASIL RENDIMIENTO TOTAL"
#    else
#      #unknown value
#      hash[:mustra] = muestra
#  end
#
#  #SECTOR NUM 2
#  sector = sequence_bytes[4...6].to_i
#  case sector
#    when 0
#      hash[:sector] = "NO ES SECTOR"
#    when 1
#      hash[:sector] = "INDUSTRIAL"
#    when 2
#      hash[:sector] = "COMERCIAL"
#    when 3
#      hash[:sector] = "SERVICIOS NO FINANCIEROS"
#    when 4
#      hash[:sector] = "SEGUROS Y BANCOS"
#    when 5
#      hash[:sector] = "CASAS DE BOLSA"
#    else
#      #DUDA en este ultimo valor(ver pag 82 del pdf)
#      hash[:sector] = "GRUPO FINANCIERO"
#  end
#
#  #SUBSECTOR NUM 2
#  subsector = sequence_bytes[6...8]
#  hash[:subsector] = (subsector == 0) ? "NO ES SUBSECTOR" : subsector
#
#  #RAMO NUM 2
#  ramo = sequence_bytes[8...10]
#  hash[:ramo] = (ramo==0) ? "NO ES RAMO" : ramo
#
#  #SUBRAMO NUM 2
#  subramo = sequence_bytes[10...12]
#  hash[:subramo] = (subramo==0) ? "NO ES UN SUBRAMO" : subramo
#
#  #HORA NUM 8
#  hora = sequence_bytes[12...20]
#  hora = hora[0...6].insert(2, ':').insert(5, ':') #dejo los ultimos 2 caracteres porque solo voy amostrar hasta los segundos
#  hash[:hora] = hora # Resultado es algo como esto 12:05:22
#
#  #NOPER NUM 6
#  noper = sequence_bytes[20...26]
#  hash[:noper] = noper
#
#  #VOLUMEN NUM 13
#  volumen = sequence_bytes[26...39].to_i
#  hash[:volumen] = volumen
#
#  #IMPORTE NUM 16,2
#  importe = sequence_bytes[39...57].insert(16, '.')
#  hash[:importe] = '%.2f' % importe.to_f
#
#  #ALZAS NUM 4
#  alzas = sequence_bytes[57...61]
#  hash[:alzas] = alzas
#
#  #BAJAS NUM 4
#  bajas = sequence_bytes[61...65]
#  hash[:bajas] = bajas
#
#  #SIN-CAMBIO NUM 4
#  sin_cambio = sequence_bytes[65...69]
#  hash[:sin_cambio] = sin_cambio
#
#  #INDICE NUM 7,2
#  indice = sequence_bytes[69...78].insert(7, ".")
#  hash[:indice] = '%.2f' % indice.to_f
#
#  #VARIACION NUM 6,2
#  variacion = sequence_bytes[78...86].insert(6, '.')
#  hash[:variacion] = '%.2f' % variacion.to_f
#
#  #PORCENTAJE NUM 3,2
#  porcentaje = sequence_bytes[86...91].insert(3, '.')
#  hash[:porcentaje] = '%.2f' % porcentaje.to_f
#
#  #TENDENCIA ALFA 1
#  tendencia = sequence_bytes[91...92].strip
#  case tendencia
#    when 'A'
#      hash[:tendencia] = 'ALZA'
#    when 'B'
#      hash[:tendencia] = 'BAJA'
#    when ''
#      hash[:tendencia] = 'SIN CAMBIO'
#    else
#      #unknown value
#      hash[:tendencia] = tendencia
#  end
#
#  #ESTADO-INDICE VALUE “AN” ALFA 2
#  estado_indice = sequence_bytes[92...94]
#  case estado_indice
#    when 'AN'
#      hash[:estado_indice] = 'ANTERIOR'
#    when 'DE'
#      hash[:estado_indice] = 'DEFINITIVO'
#    when 'ID'
#      hash[:estado_indice] = 'INDICE DEFINITIVO CON CIFRAS'
#    when 'PR'
#      hash[:estado_indice] = 'PRELIMINARES'
#    else
#      #unknown value
#      hash[:estado_indice] = estado_indice
#  end
#
#  accion_data = "Muestra: #{hash[:muestra]} Importe: #{hash[:importe]} Volumen: #{hash[:volumen]} Tendencia: #{hash[:tendencia]} Hora: #{hash[:hora]}"
#  puts "U -> #{accion_data}"
#end

# ------------------------------------------------------------------------------------

# represents a parsing engine
class ParsingEngine < Object
  private
  # -------------------------------------------------

  # header indexes
  HEADER_START_INDEX = 0 # to start in the index 0
  HEADER_END_INDEX = 33 # to take up until the index 33 (including it)

  # data indexes
  DATA_START_INDEX = 35 # to start in the index 35 (taking from the byte 36-including it-)
  DATA_END_INDEX_NO_FILLER = -4 # excluding the last 4 - 1 = 3 elements
  DATA_END_INDEX_WITH_FILLER = -3 # excluding the last 3 - 1 = 2 elements (taking the filler as data)

  # checksum indexes
  CHK_START_INDEX = -2 # taking the second to last byte
  CHK_END_INDEX = -1 # taking the last byte

  # -------------------------------------------------

  # represents a mapper between sequence types and the corresponding parsers
  MSG_PARSER_MAPPER = {
      # parser for message of type 'P'
      MSG_P_KEY => lambda { |msg_data| parse_msg_type_p(msg_data[0...MSG_P_SIZE]) },

      # parser for message of type 'E'
      MSG_E_KEY => lambda { |msg_data| parse_msg_type_e(msg_data[0...MSG_E_SIZE]) },

      ## parser for message of type 'U'
      #MSG_U => lambda { |msg_data| parse_msg_type_u(msg_data) }
  }

  # -------------------------------------------------

  # verifies whether the received bytes are damaged or corrupt
  def sequence_bytes_are_damaged(sequence_bytes, checksum)
    # getting the data (except the checksum)
    data = sequence_bytes[0..-3]

    # getting the length of the data
    data_length = data.length()

    # getting the checksum computed by BMV
    bmv_check_sum = checksum.unpack('B*')[0].to_i(2)

    # declaring the checksum computed by us
    data_chk_sum = 0

    # looping through the even indexes
    for i in (0...data_length).step(2) do
      data_chk_sum = data_chk_sum ^ data[i..i+1].unpack('B*')[0].to_i(2)
    end

    # returning if the checksums are different
    return bmv_check_sum != data_chk_sum
  end

  # splits the sequence into header, data and checksum
  def split_sequence(sequence_bytes)
    # getting header
    header = get_sequence_header(sequence_bytes)

    # getting data
    data = get_sequence_data(sequence_bytes)

    # getting checksum
    checksum = get_sequence_checksum(sequence_bytes)

    # returning the the 3 parts of the sequence
    return [header, data, checksum]
  end

  # gets the sequence header
  def get_sequence_header(sequence_bytes)
    return sequence_bytes[HEADER_START_INDEX..HEADER_END_INDEX]
  end

  # gets the sequence data
  def get_sequence_data(sequence_bytes)
    if sequence_bytes.size() % 2 == 0
      return sequence_bytes[DATA_START_INDEX..DATA_END_INDEX_WITH_FILLER]
    else
      return sequence_bytes[DATA_START_INDEX..DATA_END_INDEX_NO_FILLER]
    end
  end

  # gets the sequence checksum
  def get_sequence_checksum(sequence_bytes)
    return sequence_bytes[CHK_START_INDEX..CHK_END_INDEX]
  end

  # gets the message type from the sequence data
  def get_message_type(data)
    # returning first 2 bytes of the data
    return data[0...2].strip()
  end

  public
  # the constructor or initializer
  def initialize()
    # nothing for now
  end

  # parses the sequence bytes into useful information
  def parse_sequence(sequence_bytes)
    # attempting to parse the sequence
    begin
      # splitting the sequence into header, data and checksum
      _, data, checksum = split_sequence(sequence_bytes)

      # if there was a checksum error
      if sequence_bytes_are_damaged(sequence_bytes, checksum)
        return [ParsingErrorType::CHECKSUM_ERROR, nil]
      end

      # getting message type
      type = get_message_type(data)

      # getting sequence id
      id = get_sequence_id(sequence_bytes)

      # getting sequence hour
      hour = get_sequence_hour(sequence_bytes)

      # printing type of message to the console
      # puts("Received message of type:\t#{type}")
      puts("parseado Type:#{type} Sequence id:#{id} Hora:#{hour}")

      # if the message type is nor supported
      unless MSG_PARSER_MAPPER.has_key?(type)
        return [ParsingErrorType::UNSUPPORTED_MSG_TYPE_ERROR, nil]
      end

      # actually parsing the message data
      return MSG_PARSER_MAPPER[type].call(data)
    rescue Exception
      # returning an unknown parsing error
      return [ParsingErrorType::UNKNOWN_ERROR, nil]
    end
  end

  # gets the id from the sequence from it's bytes
  def get_sequence_id(sequence_bytes)
    # getting the header
    header = get_sequence_header(sequence_bytes)

    # attempt to get the id of the sequence
    return header[4..14].to_i()
  end

  # gets the hour of the data transmission
  def get_sequence_hour(sequence_bytes)
    # getting the header
    header = get_sequence_header(sequence_bytes)

    # attempt to get the hour of the data transmission
    return header[15..22]
  end
end