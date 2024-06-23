class Product < ApplicationRecord
  belongs_to :user

  # Valida que el campo categories no esté vacío.
  validates :categories, presence: true, inclusion: { in: ['Cancha', 'Accesorio tecnologico',
                                                           'Accesorio deportivo', 'Accesorio de vestir',
                                                           'Accesorio de entrenamiento', 'Suplementos',
                                                           'Equipamiento'] }

  # Valida que el campo nombre no esté vacío.
  validates :nombre, presence: true

  # Valida que el campo stock no esté vacío y sea un número mayor o igual a 0.
  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Valida que el campo precio no esté vacío y sea un número mayor o igual a 0.
  validates :precio, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # Valida que el campo user_id no esté vacío.

  # Contiene una imagen como attachment.
  has_one_attached :image

  # Establece la relación con el modelo Review y destruye las reviews asociadas cuando se elimina el producto.
  has_many :reviews, dependent: :destroy

  # Establece la relación con el modelo Message y destruye los mensajes asociados cuando se elimina el producto.
  has_many :messages, dependent: :destroy

  # Establece la relación con el modelo Solicitud y destruye las solicitudes asociadas cuando se elimina el producto.
  has_many :solicituds, dependent: :destroy
  validates :stock, numericality: { greater_than_or_equal_to: 0 }
  validates :precio, numericality: { greater_than_or_equal_to: 0 }

  def day_to_number(day_name)
    days = {
      'Monday' => 1,
      'Tuesday' => 2,
      'Wednesday' => 3,
      'Thursday' => 4,
      'Friday' => 5,
      'Saturday' => 6,
      'Sunday' => 7,
    }
    days[day_name]
  end

  def date_on_range(start_day, end_day, start_hour, end_hour, reserva)
    start_time = Time.parse(start_hour)
    end_time = Time.parse(end_hour)  
    reserva_datetime = reserva.is_a?(String) ? DateTime.parse(reserva) : reserva
    reserva_day = reserva_datetime.wday
    reserva_time = Time.parse(reserva_datetime.strftime("%I:%M %p"))
    if reserva_day == start_day && reserva_day != end_day
      time_in_range = start_time <= reserva_time
      return time_in_range
    elsif reserva_day == end_day && reserva_day != start_day
      time_in_range = reserva_time <= end_time
      return time_in_range
    elsif reserva_day == start_day && reserva_day == end_day
      time_in_range = start_time <= reserva_time && reserva_time <= end_time
      return time_in_range
    elsif reserva_day > start_day && reserva_day < end_day
      return true
    elsif start_day > end_day
      return (reserva_day > start_day || reserva_day < end_day)
    else
      return false
    end
  end

end
