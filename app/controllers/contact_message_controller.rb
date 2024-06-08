class ContactMessageController < ApplicationController
  def crear
    @contact_message = ContactMessage.new(contact_message_params)
    if @contact_message.save
      flash[:notice] = 'Mensaje de contacto enviado correctamente'
    else
      flash[:alert] =
        "Error al enviar el mensaje de contacto: #{@contact_message.errors.full_messages.join(', ')}"
    end
    redirect_to '/contacto'
  end

  def mostrar
    @contact_messages = ContactMessage.all.order(created_at: :desc)
    render 'contacto'
  end

  def eliminar
    if current_user.role == 'admin'
      @contact_message = ContactMessage.find_by(id: params[:id])
      if !@contact_message.nil? && @contact_message.destroy
        flash[:notice] = 'Mensaje de contacto eliminado correctamente'
      else
        flash[:alert] = 'Error al eliminar el mensaje de contacto'
      end
    else
      flash[:alert] = 'Debes ser un administrador para eliminar un mensaje de contacto.'
    end
    redirect_to '/contacto'
  end

  def limpiar
    if current_user.role == 'admin'
      @contact_messages = ContactMessage.all
      if !@contact_messages.empty? && @contact_messages.destroy_all
        flash[:notice] = 'Mensajes de contacto eliminados correctamente'
      else
        flash[:alert] = 'Error al eliminar los mensajes de contacto'
      end
    else
      flash[:alert] = 'Debes ser un administrador para eliminar los mensajes de contacto.'
    end
    redirect_to '/contacto'
  end

  private

  def contact_message_params
    params.require(:contact).permit(:name, :mail, :phone, :title, :body)
  end
end
