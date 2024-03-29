USE dw_lowlatency

create or alter procedure sp_oltp_loja(@data_carga datetime)
as
begin
	DECLARE @COD_LOJA INT, @NM_LOJA VARCHAR(100), @COD_CIDADE_LOJA INT, @COD_CIDADE INT, @CIDADE VARCHAR(100), @COD_ESTADO_CIDADE INT, @COD_ESTADO INT, @ESTADO VARCHAR(100), @SIGLA VARCHAR(100), @DT_CARGA DATETIME

	DECLARE C_LOJA CURSOR FOR
	SELECT COD_LOJA, NM_LOJA, COD_CIDADE FROM TB_LOJA
	OPEN C_LOJA
	FETCH C_LOJA INTO @COD_LOJA, @NM_LOJA, @COD_CIDADE_LOJA

	WHILE(@@FETCH_STATUS = 0)
	BEGIN
		DECLARE C_CIDADE CURSOR FOR
		SELECT COD_CIDADE, CIDADE, COD_ESTADO FROM TB_CIDADE
		OPEN C_CIDADE
		FETCH C_CIDADE INTO @COD_CIDADE, @CIDADE, @COD_ESTADO_CIDADE

		WHILE (@@FETCH_STATUS = 0)
		BEGIN
			DECLARE C_ESTADO CURSOR FOR
			SELECT COD_ESTADO, ESTADO, SIGLA FROM TB_ESTADO
			OPEN C_ESTADO
			FETCH C_ESTADO INTO @COD_ESTADO, @ESTADO, @SIGLA

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				IF (@COD_CIDADE_LOJA = @COD_CIDADE AND @COD_ESTADO_CIDADE = @COD_ESTADO)
				BEGIN
					INSERT INTO TB_AUX_LOJA VALUES (@data_carga, @COD_LOJA, @NM_LOJA, @CIDADE, @ESTADO, @SIGLA)
				END

				FETCH C_ESTADO INTO @COD_ESTADO, @ESTADO, @SIGLA
			END

			CLOSE C_ESTADO
			DEALLOCATE C_ESTADO

			FETCH C_CIDADE INTO @COD_CIDADE, @CIDADE, @COD_ESTADO_CIDADE
		END

		CLOSE C_CIDADE
		DEALLOCATE C_CIDADE

		FETCH C_LOJA INTO @COD_LOJA, @NM_LOJA, @COD_CIDADE_LOJA
	END

	CLOSE C_LOJA
	DEALLOCATE C_LOJA
end

-- Teste

exec sp_oltp_loja '20230321'

TRUNCATE TABLE TB_AUX_LOJA

select * from tb_aux_loja
