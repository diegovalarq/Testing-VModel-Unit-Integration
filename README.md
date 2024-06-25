## Tarea X

### Logros de la entrega:
[Recuerden especificar quien hizo cada cosa]
* Sanchez unit, CI
* Valenzuela Integration

### Informacion para el correcto:
Incluir aqui cualquier detalle que pueda ser importante al momento de corregir.

#### Modificación de app
* Respecto a las reservas, se verifica que la fecha de reserva corresponda a los horarios del producto. Para ello contemplamos los siguientes supuestos:
1. Los días se ingresan en inglés, de la siguiente forma: Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday.
* se añadió la validación de la fecha y hora de una reserva en el solicitud_controller.

#### Test de Sistema
1. Visiting Canchas y productos as regular user from landing page, it have Canchas y productos h1: Inicio: Landing page, Fin: /products/index
2. Visiting Cancha post as regular user from landing page, it have Cancha fútbol p: Inicio: Landing page, Fin: /products/leer/:id
3. Visiting Cancha post as regular user from landing page, it have price: Inicio: Landing page, Fin: /products/leer/:id
4. visiting solicitud created by regular user, it solicitud of Cancha fútbol: Inicio: Landing page, Fin: /solicitud/index


Nos hemos apoyado en GPT para generar los tests, en especial de shoppingcart, pues eran muchos casos y muy confusos

Se han borrado lineas que se creian obstaculizaban el funcionamiento de los tests, especialmente los controladores, como review, product.

Referencias visitadas:
https://www.youtube.com/watch?v=I9dz2w0bIGE
https://www.youtube.com/watch?v=K6RPMhcRICE&list=PLr442xinba86s9cCWxoIH_xq5UE9Wwo4Z
https://rspec.info/features/6-0/rspec-rails/controller-specs/
https://www.rubyguides.com/2019/11/rails-flash-messages/