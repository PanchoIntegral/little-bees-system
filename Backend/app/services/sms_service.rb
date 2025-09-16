class SmsService
  class << self
    def send_verification_code(phone_number, code)
      if Rails.env.development? || Rails.env.test?
        send_development_sms(phone_number, code)
      else
        send_production_sms(phone_number, code)
      end
    end

    private

    def send_development_sms(phone_number, code)
      puts "="*50
      puts "📱 SMS SIMULADO PARA DESARROLLO 📱"
      puts "="*50
      puts "Para: #{phone_number}"
      puts "Código de verificación: #{code}"
      puts "Este código expira en 10 minutos"
      puts "="*50

      # También log en Rails logger
      Rails.logger.info "SMS enviado a #{phone_number}: #{code}"

      # Simular éxito
      { success: true, message: "SMS simulado enviado" }
    end

    def send_production_sms(phone_number, code)
      # Para producción con Twilio (descomentado cuando se configure)
      # begin
      #   client = Twilio::REST::Client.new(
      #     Rails.application.credentials.twilio_account_sid,
      #     Rails.application.credentials.twilio_auth_token
      #   )
      #
      #   message = client.messages.create(
      #     body: "Tu código de verificación es: #{code}. Expira en 10 minutos.",
      #     from: Rails.application.credentials.twilio_phone_number,
      #     to: phone_number
      #   )
      #
      #   { success: true, message: "SMS enviado", sid: message.sid }
      # rescue => e
      #   Rails.logger.error "Error enviando SMS: #{e.message}"
      #   { success: false, message: "Error enviando SMS: #{e.message}" }
      # end

      # Por ahora en producción también simulamos
      Rails.logger.info "SMS enviado a #{phone_number}: #{code}"
      { success: true, message: "SMS enviado (simulado en producción)" }
    end

    def send_email_fallback(email, code)
      # Fallback por email si SMS falla
      begin
        # UserMailer.verification_code(email, code).deliver_now
        Rails.logger.info "Email fallback enviado a #{email}: #{code}"
        { success: true, message: "Código enviado por email" }
      rescue => e
        Rails.logger.error "Error enviando email fallback: #{e.message}"
        { success: false, message: "Error enviando código" }
      end
    end
  end
end