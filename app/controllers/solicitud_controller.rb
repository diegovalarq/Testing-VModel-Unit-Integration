# Controlador para gestionar las solicitudes de compra
class SolicitudController < ApplicationController
  # Muestra las solicitudes y productos asociados del usuario actual
  def index
    @solicitudes = Solicitud.where(user_id: current_user.id)
    @productos = Product.where(user_id: current_user.id)
  end

  # rubocop:disable Metrics
  # Crea una nueva solicitud de compra
  def insertar
    @solicitud = Solicitud.new
    @solicitud.status = 'Pendiente'
    @solicitud.stock = parametros[:stock]
    producto = Product.find(params[:product_id])
    @solicitud.product_id = producto.id
    @solicitud.user_id = current_user.id

    if @solicitud.stock.to_i > producto.stock.to_i
      flash[:error] = 'No hay suficiente stock para realizar la solicitud!'
      redirect_to "/products/leer/#{params[:product_id]}"
      return
    else
      producto.stock = producto.stock.to_i - @solicitud.stock.to_i
    end

    if producto.horarios.present?
      if params[:solicitud][:reservation_datetime].blank?
        flash[:error] = 'Debe seleccionar una fecha y hora para la reserva!'
        redirect_to "/products/leer/#{params[:product_id]}"
        return
      end
      dias = producto.horarios.split(';')
      horarios = []
      dias.each do |dia|
        horario = dia.split(',')
        day = producto.day_to_number(horario[0])
        start_hour = Time.zone.parse(horario[1])
        end_hour = Time.zone.parse(horario[2])
        horarios << [day, start_hour, end_hour]
      end

      reserva_date = params[:solicitud][:reservation_datetime].to_datetime
      reserva_datetime = reserva_date.is_a?(String) ? DateTime.parse(reserva_date) : reserva_date
      reserva_day = reserva_datetime.wday
      reserva_time = Time.zone.parse(reserva_datetime.strftime('%I:%M %p'))

      valid_reservation = false
      horarios.each do |horario|
        if horario[0] == reserva_day && (horario[1] <= reserva_time && horario[2] >= reserva_time)
          valid_reservation = true
          break
        end
      end

      if valid_reservation == false
        flash[:error] = 'No hay reservas disponibles en el día y hora seleccionada!'
        redirect_to "/products/leer/#{params[:product_id]}"
        return
      else
        dia = reserva_datetime.strftime('%d/%m/%Y')
        hora = reserva_datetime.strftime('%H:%M')
        @solicitud.reservation_info = "Solicitud de reserva para el día #{dia}, a las #{hora} hrs"
      end
    elsif params[:solicitud][:reservation_datetime].present?
      fecha = params[:solicitud][:reservation_datetime].to_datetime
      dia = fecha.strftime('%d/%m/%Y')
      hora = fecha.strftime('%H:%M')
      @solicitud.reservation_info = "Solicitud de reserva para el día #{dia}, a las #{hora} hrs"
    end

    if @solicitud.save && producto.update(stock: producto.stock)
      flash[:notice] = 'Solicitud de compra creada correctamente!'
      redirect_to "/products/leer/#{params[:product_id]}"
    else
      flash[:error] = 'Hubo un error al guardar la solicitud!'
      redirect_to "/products/leer/#{params[:product_id]}"
      Rails.logger.debug @solicitud.errors.full_messages
    end
  end

  # rubocop:enable Metrics
  # Elimina una solicitud de compra
  def eliminar
    @solicitud = Solicitud.find(params[:id])
    producto = Product.find(@solicitud.product_id)
    producto.stock = producto.stock.to_i + @solicitud.stock.to_i

    if @solicitud.destroy && producto.update(stock: producto.stock)
      flash[:notice] = 'Solicitud eliminada correctamente!'
    else
      flash[:error] = 'Hubo un error al eliminar la solicitud!'
    end
    redirect_to '/solicitud/index'
  end

  # Actualiza el estado de una solicitud a "Aprobada"
  def actualizar
    @solicitud = Solicitud.find(params[:id])
    @solicitud.status = 'Aprobada'

    if @solicitud.update(status: @solicitud.status)
      flash[:notice] = 'Solicitud aprobada correctamente!'
    else
      flash[:error] = 'Hubo un error al aprobar la solicitud!'
    end
    redirect_to '/solicitud/index'
  end

  private

  # Permite los parámetros necesarios para la creación de una solicitud
  def parametros
    params.require(:solicitud).permit(:stock,
                                      :reservation_datetime).merge(product_id: params[:product_id])
  end
end
