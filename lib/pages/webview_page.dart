import 'package:flutter/material.dart';
import 'package:freeway_app/locatordevice/presentation/widgets/loading_view.dart';
import 'package:freeway_app/utils/app_localizations_extension.dart';
import 'package:freeway_app/widgets/theme/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewPage extends StatefulWidget {
  final String url;
  final String title;
  final Map<String, String>? userData;
  final String? formType;

  const WebViewPage({
    required this.url,
    required this.title,
    this.userData,
    this.formType,
    super.key,
  });

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isFormFillingComplete = false; // Nueva variable de estado

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _isFormFillingComplete =
                    false; // Reiniciar al iniciar nueva página
              });
            }
          },
          onPageFinished: (String url) async {
            // Actualizar el estado de navegación
            await _updateBackNavigationState();

            // Si tenemos datos de usuario, intentamos prellenar el formulario
            if (widget.userData != null) {
              await _injectFormFillingScript();
              if (mounted) {
                setState(() {
                  _isFormFillingComplete =
                      true; // El script de llenado ha terminado
                });
              }
            } else {
              // Si no hay datos de usuario, consideramos que el llenado "ha terminado"
              if (mounted) {
                setState(() {
                  _isFormFillingComplete = true;
                });
              }
            }

            // Solo ocultar el loading cuando la página esté cargada Y el llenado del formulario haya terminado
            if (_isFormFillingComplete) {
              // Agregamos un retraso adicional de 2 segundos para asegurar que todo esté completamente cargado
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  // Verificamos que el widget aún esté montado
                  setState(() {
                    _isLoading = false;
                  });
                }
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) async {
            // Actualizar el estado de navegación después de cada cambio de URL
            Future.delayed(const Duration(milliseconds: 300), () {
              _updateBackNavigationState();
            });
            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  // Método para inyectar JavaScript que rellena automáticamente los formularios
  Future<void> _injectFormFillingScript() async {
    if (widget.userData == null) return;

    final userData = widget.userData!;
    final formType = widget.formType ?? '';

    // Crear un script JavaScript basado en el tipo de formulario
    String script = '';

    // Script genérico para buscar campos comunes por ID, nombre, o atributos
    script = '''
      (function() {
        // Función para encontrar y rellenar campos por diferentes atributos
        function fillField(selectors, value) {
          if (!value) return;
          
          for (let selector of selectors) {
            const elements = document.querySelectorAll(selector);
            for (let el of elements) {
              if (el && !el.value) {
                el.value = value;
                // Disparar evento de cambio para activar validaciones
                const event = new Event('input', { bubbles: true });
                el.dispatchEvent(event);
                return true; // Campo encontrado y rellenado
              }
            }
          }
          return false; // No se encontró el campo
        }
        
        // Datos del usuario
        const userData = ${_mapToJsObject(userData)};
        
        // Esperar a que el DOM esté completamente cargado
        setTimeout(function() {
          // Intentar rellenar campos comunes
          fillField(['#firstName', '#tbFirstName', '#form_insurance_your_first_name', 'input[name="firstName"]', 'input[name="lead[first_name]"]', '.firstName', 'input[placeholder*="nombre"]', 'input[placeholder*="first"]', '[data-field="first-name"]'], userData.firstName);
          fillField(['#lastName', '#tbLastName', '#form_insurance_your_last_name', 'input[name="lastName"]', 'input[name="lead[last_name]"]', '.lastName', 'input[placeholder*="apellido"]', 'input[placeholder*="last"]', '[data-field="last-name"]'], userData.lastName);
          fillField(['#email', '#tbEmail', 'input[type="email"]', 'input[name="email"]', 'input[name="lead[email]"]', 'input[placeholder*="email"]', 'input[placeholder*="correo"]', '[data-field="email-address"]'], userData.email);
          fillField(['#phone', '#tbPhoneNumber', 'input[type="tel"]', 'input[name="phone"]', 'input[name="lead[phone]"]', 'input[placeholder*="phone"]', 'input[placeholder*="teléfono"]', 'input[placeholder*="telefono"]', '[data-field="phone-number"]'], userData.phone);
          fillField(['#zipCode', '#postal_code', 'input[name="zipCode"]', 'input[name="lead[zip]"]', 'input[placeholder*="zip"]', 'input[placeholder*="código postal"]', 'input[placeholder*="codigo postal"]', '[data-field="zip-code"]'], userData.zipCode);
          fillField(['#city', 'input[name="city"]', 'input[name="lead[city]"]', 'input[placeholder*="city"]', 'input[placeholder*="ciudad"]'], userData.city);
          fillField(['#state', 'input[name="state"]', 'input[name="lead[state]"]', 'input[placeholder*="state"]', 'input[placeholder*="estado"]'], userData.state);
          fillField(['#birthDate', '#tbDateOfBirth', 'input[name="birthDate"]', 'input[placeholder*="nacimiento"]', 'input[placeholder*="birth"]', '[data-field="date-of-birth"]'], userData.birthDate);
          fillField(['#street', '#form_insurance_street_address', '.address', 'input[name="street"]', 'input[name="lead[street]"]', 'input[placeholder*="dirección"]', 'input[placeholder*="address"]', 'input[autocomplete="street-address"]'], userData.street);
          
          // Lógica específica para diferentes tipos de formularios
          switch('$formType') {
            case 'auto':
              // Lógica específica para formularios de auto de Triton
              console.log('Aplicando lógica específica para formulario de auto');
              
              // Intentar nuevamente después de un tiempo adicional (algunos formularios cargan dinámicamente)
              setTimeout(function() {
                fillField(['#tbFirstName', '[data-field="first-name"]'], userData.firstName);
                fillField(['#tbLastName', '[data-field="last-name"]'], userData.lastName);
                fillField(['#tbEmail', '[data-field="email-address"]'], userData.email);
                fillField(['#tbPhoneNumber', '[data-field="phone-number"]'], userData.phone);
                fillField(['#postal_code', '[data-field="zip-code"]'], userData.zipCode);
                fillField(['#tbDateOfBirth', '[data-field="date-of-birth"]'], userData.birthDate);
                
                // Activar cualquier evento necesario después de rellenar
                const inputs = document.querySelectorAll('#tbFirstName, #tbLastName, #tbEmail, #tbPhoneNumber, #postal_code, #tbDateOfBirth');
                inputs.forEach(input => {
                  if (input) {
                    // Disparar múltiples eventos para asegurar la compatibilidad
                    ['input', 'change', 'blur'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
              }, 1000);
              break;

            case 'hospital_indemnity':
              // Lógica específica para formulario de Auto Club
              console.log('Aplicando lógica específica para formulario de Auto Club');
              
              // Intentar rellenar los campos del formulario después de que cargue completamente
              setTimeout(function() {
                // Campos del formulario según los atributos name del HTML
                fillField(['input[name="first_name"]', '#first-name', 'input[id="first-name"]'], userData.firstName);
                fillField(['input[name="last_name"]', '#last-name', 'input[id="last-name"]'], userData.lastName);
                fillField(['input[name="user_address[address]"]', '#address', 'input[id="address"]'], userData.street);
                fillField(['input[name="zipcode"]', '#zipcode', 'input[id="zipcode"]'], userData.zipCode);
                fillField(['input[name="user_address[city]"]', '#city', 'input[id="city"]'], userData.city);
                fillField(['input[name="user_address[state]"]', '#state', 'input[id="state"]'], userData.state);
                fillField(['input[name="email"]', '#email', 'input[id="email"]'], userData.email);
                fillField(['input[name="phone"]', '#phone', 'input[id="phone"]'], userData.phone);
                
                // Activar eventos para asegurar que los campos se validen correctamente
                const autoClubInputs = document.querySelectorAll('.form__item input');
                autoClubInputs.forEach(input => {
                  if (input && input.value) {
                    console.log('Activando eventos para:', input.name || input.id);
                    ['input', 'change', 'blur', 'focus'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
                
                // Intentar hacer scroll al botón de continuar
                const continueButton = document.querySelector('button[type="submit"], .form__button, .btn-primary');
                if (continueButton) {
                  continueButton.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }, 2000); // Esperar 2 segundos para asegurar que el formulario está cargado
              break;

            case 'identity_theft_protection':
              // Lógica específica para formulario de Auto Club
              console.log('Aplicando lógica específica para formulario de Auto Club');
              
              // Intentar rellenar los campos del formulario después de que cargue completamente
              setTimeout(function() {
                // Campos del formulario según los atributos name del HTML
                fillField(['input[name="first_name"]', '#first-name', 'input[id="first-name"]'], userData.firstName);
                fillField(['input[name="last_name"]', '#last-name', 'input[id="last-name"]'], userData.lastName);
                fillField(['input[name="user_address[address]"]', '#address', 'input[id="address"]'], userData.street);
                fillField(['input[name="zipcode"]', '#zipcode', 'input[id="zipcode"]'], userData.zipCode);
                fillField(['input[name="user_address[city]"]', '#city', 'input[id="city"]'], userData.city);
                fillField(['input[name="user_address[state]"]', '#state', 'input[id="state"]'], userData.state);
                fillField(['input[name="email"]', '#email', 'input[id="email"]'], userData.email);
                fillField(['input[name="phone"]', '#phone', 'input[id="phone"]'], userData.phone);
                
                // Activar eventos para asegurar que los campos se validen correctamente
                const autoClubInputs = document.querySelectorAll('.form__item input');
                autoClubInputs.forEach(input => {
                  if (input && input.value) {
                    console.log('Activando eventos para:', input.name || input.id);
                    ['input', 'change', 'blur', 'focus'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
                
                // Intentar hacer scroll al botón de continuar
                const continueButton = document.querySelector('button[type="submit"], .form__button, .btn-primary');
                if (continueButton) {
                  continueButton.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }, 2000); // Esperar 2 segundos para asegurar que el formulario está cargado
              break;

            case 'telemedicine':
              // Lógica específica para formulario de Auto Club
              console.log('Aplicando lógica específica para formulario de Auto Club');
              
              // Intentar rellenar los campos del formulario después de que cargue completamente
              setTimeout(function() {
                // Campos del formulario según los atributos name del HTML
                fillField(['input[name="first_name"]', '#first-name', 'input[id="first-name"]'], userData.firstName);
                fillField(['input[name="last_name"]', '#last-name', 'input[id="last-name"]'], userData.lastName);
                fillField(['input[name="user_address[address]"]', '#address', 'input[id="address"]'], userData.street);
                fillField(['input[name="zipcode"]', '#zipcode', 'input[id="zipcode"]'], userData.zipCode);
                fillField(['input[name="user_address[city]"]', '#city', 'input[id="city"]'], userData.city);
                fillField(['input[name="user_address[state]"]', '#state', 'input[id="state"]'], userData.state);
                fillField(['input[name="email"]', '#email', 'input[id="email"]'], userData.email);
                fillField(['input[name="phone"]', '#phone', 'input[id="phone"]'], userData.phone);
                
                // Activar eventos para asegurar que los campos se validen correctamente
                const autoClubInputs = document.querySelectorAll('.form__item input');
                autoClubInputs.forEach(input => {
                  if (input && input.value) {
                    console.log('Activando eventos para:', input.name || input.id);
                    ['input', 'change', 'blur', 'focus'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
                
                // Intentar hacer scroll al botón de continuar
                const continueButton = document.querySelector('button[type="submit"], .form__button, .btn-primary');
                if (continueButton) {
                  continueButton.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }, 2000); // Esperar 2 segundos para asegurar que el formulario está cargado
              break;

            case 'windshield_repair':
              // Lógica específica para formulario de Auto Club
              console.log('Aplicando lógica específica para formulario de Auto Club');
              
              // Intentar rellenar los campos del formulario después de que cargue completamente
              setTimeout(function() {
                // Campos del formulario según los atributos name del HTML
                fillField(['input[name="first_name"]', '#first-name', 'input[id="first-name"]'], userData.firstName);
                fillField(['input[name="last_name"]', '#last-name', 'input[id="last-name"]'], userData.lastName);
                fillField(['input[name="user_address[address]"]', '#address', 'input[id="address"]'], userData.street);
                fillField(['input[name="zipcode"]', '#zipcode', 'input[id="zipcode"]'], userData.zipCode);
                fillField(['input[name="user_address[city]"]', '#city', 'input[id="city"]'], userData.city);
                fillField(['input[name="user_address[state]"]', '#state', 'input[id="state"]'], userData.state);
                fillField(['input[name="email"]', '#email', 'input[id="email"]'], userData.email);
                fillField(['input[name="phone"]', '#phone', 'input[id="phone"]'], userData.phone);
                
                // Activar eventos para asegurar que los campos se validen correctamente
                const autoClubInputs = document.querySelectorAll('.form__item input');
                autoClubInputs.forEach(input => {
                  if (input && input.value) {
                    console.log('Activando eventos para:', input.name || input.id);
                    ['input', 'change', 'blur', 'focus'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
                
                // Intentar hacer scroll al botón de continuar
                const continueButton = document.querySelector('button[type="submit"], .form__button, .btn-primary');
                if (continueButton) {
                  continueButton.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }, 2000); // Esperar 2 segundos para asegurar que el formulario está cargado
              break;

            case 'tire_hazard_protection':
              // Lógica específica para formulario de Auto Club
              console.log('Aplicando lógica específica para formulario de Auto Club');
              
              // Intentar rellenar los campos del formulario después de que cargue completamente
              setTimeout(function() {
                // Campos del formulario según los atributos name del HTML
                fillField(['input[name="first_name"]', '#first-name', 'input[id="first-name"]'], userData.firstName);
                fillField(['input[name="last_name"]', '#last-name', 'input[id="last-name"]'], userData.lastName);
                fillField(['input[name="user_address[address]"]', '#address', 'input[id="address"]'], userData.street);
                fillField(['input[name="zipcode"]', '#zipcode', 'input[id="zipcode"]'], userData.zipCode);
                fillField(['input[name="user_address[city]"]', '#city', 'input[id="city"]'], userData.city);
                fillField(['input[name="user_address[state]"]', '#state', 'input[id="state"]'], userData.state);
                fillField(['input[name="email"]', '#email', 'input[id="email"]'], userData.email);
                fillField(['input[name="phone"]', '#phone', 'input[id="phone"]'], userData.phone);
                
                // Activar eventos para asegurar que los campos se validen correctamente
                const autoClubInputs = document.querySelectorAll('.form__item input');
                autoClubInputs.forEach(input => {
                  if (input && input.value) {
                    console.log('Activando eventos para:', input.name || input.id);
                    ['input', 'change', 'blur', 'focus'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
                
                // Intentar hacer scroll al botón de continuar
                const continueButton = document.querySelector('button[type="submit"], .form__button, .btn-primary');
                if (continueButton) {
                  continueButton.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }, 2000); // Esperar 2 segundos para asegurar que el formulario está cargado
              break;

            case 'dent_repair':
              // Lógica específica para formulario de Auto Club
              console.log('Aplicando lógica específica para formulario de Auto Club');
              
              // Intentar rellenar los campos del formulario después de que cargue completamente
              setTimeout(function() {
                // Campos del formulario según los atributos name del HTML
                fillField(['input[name="first_name"]', '#first-name', 'input[id="first-name"]'], userData.firstName);
                fillField(['input[name="last_name"]', '#last-name', 'input[id="last-name"]'], userData.lastName);
                fillField(['input[name="user_address[address]"]', '#address', 'input[id="address"]'], userData.street);
                fillField(['input[name="zipcode"]', '#zipcode', 'input[id="zipcode"]'], userData.zipCode);
                fillField(['input[name="user_address[city]"]', '#city', 'input[id="city"]'], userData.city);
                fillField(['input[name="user_address[state]"]', '#state', 'input[id="state"]'], userData.state);
                fillField(['input[name="email"]', '#email', 'input[id="email"]'], userData.email);
                fillField(['input[name="phone"]', '#phone', 'input[id="phone"]'], userData.phone);
                
                // Activar eventos para asegurar que los campos se validen correctamente
                const autoClubInputs = document.querySelectorAll('.form__item input');
                autoClubInputs.forEach(input => {
                  if (input && input.value) {
                    console.log('Activando eventos para:', input.name || input.id);
                    ['input', 'change', 'blur', 'focus'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
                
                // Intentar hacer scroll al botón de continuar
                const continueButton = document.querySelector('button[type="submit"], .form__button, .btn-primary');
                if (continueButton) {
                  continueButton.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }, 2000); // Esperar 2 segundos para asegurar que el formulario está cargado
              break;
              
            case 'motorcycle':
              // Lógica específica para formularios de motocicleta
              console.log('Aplicando lógica específica para formulario de motocicleta');
              
              // Intentar nuevamente después de un tiempo adicional (algunos formularios cargan dinámicamente)
              setTimeout(function() {
                // Selectores específicos para el formulario de motocicleta
                fillField(['#form_insurance_your_first_name', '.firstName', 'input[name="lead[first_name]"]'], userData.firstName);
                fillField(['#form_insurance_your_last_name', '.lastName', 'input[name="lead[last_name]"]'], userData.lastName);
                fillField(['#form_insurance_street_address', '.address', 'input[name="lead[street]"]'], userData.street);
                
                // Activar cualquier evento necesario después de rellenar
                const inputs = document.querySelectorAll('#form_insurance_your_first_name, #form_insurance_your_last_name, #form_insurance_street_address');
                inputs.forEach(input => {
                  if (input) {
                    // Disparar múltiples eventos para asegurar la compatibilidad
                    ['input', 'change', 'blur'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
              }, 1000);
              break;

            case 'motorhome':
              // Lógica específica para formularios de motocicleta
              console.log('Aplicando lógica específica para formulario de motocicleta');
              
              // Intentar nuevamente después de un tiempo adicional (algunos formularios cargan dinámicamente)
              setTimeout(function() {
                // Selectores específicos para el formulario de motocicleta
                fillField(['#form_insurance_your_first_name', '.firstName', 'input[name="lead[first_name]"]'], userData.firstName);
                fillField(['#form_insurance_your_last_name', '.lastName', 'input[name="lead[last_name]"]'], userData.lastName);
                fillField(['#form_insurance_street_address', '.address', 'input[name="lead[street]"]'], userData.street); // Corregido: userData.stree a userData.street
                
                // Activar cualquier evento necesario después de rellenar
                const inputs = document.querySelectorAll('#form_insurance_your_first_name, #form_insurance_your_last_name, #form_insurance_street_address');
                inputs.forEach(input => {
                  if (input) {
                    // Disparar múltiples eventos para asegurar la compatibilidad
                    ['input', 'change', 'blur'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
              }, 1000);
              break;

            case 'rv_motorhome':
              // Lógica específica para formularios de motocicleta
              console.log('Aplicando lógica específica para formulario de motocicleta');
              
              // Intentar nuevamente después de un tiempo adicional (algunos formularios cargan dinámicamente)
              setTimeout(function() {
                // Selectores específicos para el formulario de motocicleta
                fillField(['#form_insurance_your_first_name', '.firstName', 'input[name="lead[first_name]"]'], userData.firstName);
                fillField(['#form_insurance_your_last_name', '.lastName', 'input[name="lead[last_name]"]'], userData.lastName);
                fillField(['#form_insurance_street_address', '.address', 'input[name="lead[street]"]'], userData.street);
                
                // Activar cualquier evento necesario después de rellenar
                const inputs = document.querySelectorAll('#form_insurance_your_first_name, #form_insurance_your_last_name, #form_insurance_street_address');
                inputs.forEach(input => {
                  if (input) {
                    // Disparar múltiples eventos para asegurar la compatibilidad
                    ['input', 'change', 'blur'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
              }, 1000);
              break;
            
            case 'snowmobile':
              // Lógica específica para formularios de motocicleta
              console.log('Aplicando lógica específica para formulario de motocicleta');
              
              // Intentar nuevamente después de un tiempo adicional (algunos formularios cargan dinámicamente)
              setTimeout(function() {
                // Selectores específicos para el formulario de motocicleta
                fillField(['#form_insurance_your_first_name', '.firstName', 'input[name="lead[first_name]"]'], userData.firstName);
                fillField(['#form_insurance_your_last_name', '.lastName', 'input[name="lead[last_name]"]'], userData.lastName);
                fillField(['#form_insurance_street_address', '.address', 'input[name="lead[street]"]'], userData.street);
                
                // Activar cualquier evento necesario después de rellenar
                const inputs = document.querySelectorAll('#form_insurance_your_first_name, #form_insurance_your_last_name, #form_insurance_street_address');
                inputs.forEach(input => {
                  if (input) {
                    // Disparar múltiples eventos para asegurar la compatibilidad
                    ['input', 'change', 'blur'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
              }, 1000);
              break;
            
            case 'classic_car':
              // Lógica específica para formularios de auto de Triton
              console.log('Aplicando lógica específica para formulario de auto');
              
              // Intentar nuevamente después de un tiempo adicional (algunos formularios cargan dinámicamente)
              setTimeout(function() {
                fillField(['#tbFirstName', '[data-field="first-name"]'], userData.firstName);
                fillField(['#tbLastName', '[data-field="last-name"]'], userData.lastName);
                fillField(['#tbEmail', '[data-field="email-address"]'], userData.email);
                fillField(['#tbPhoneNumber', '[data-field="phone-number"]'], userData.phone);
                fillField(['#postal_code', '[data-field="zip-code"]'], userData.zipCode);
                fillField(['#tbDateOfBirth', '[data-field="date-of-birth"]'], userData.birthDate);
                
                // Activar cualquier evento necesario después de rellenar
                const inputs = document.querySelectorAll('#tbFirstName, #tbLastName, #tbEmail, #tbPhoneNumber, #postal_code, #tbDateOfBirth');
                inputs.forEach(input => {
                  if (input) {
                    // Disparar múltiples eventos para asegurar la compatibilidad
                    ['input', 'change', 'blur'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
              }, 1000);
              break;
            
            case 'sr22':
              // Lógica específica para formularios de SR22 de Triton
              console.log('Aplicando lógica específica para formulario de SR22');
              
              // Intentar nuevamente después de un tiempo adicional (algunos formularios cargan dinámicamente)
              setTimeout(function() {
                fillField(['#tbFirstName', '[data-field="first-name"]'], userData.firstName);
                fillField(['#tbLastName', '[data-field="last-name"]'], userData.lastName);
                fillField(['#tbEmail', '[data-field="email-address"]'], userData.email);
                fillField(['#tbPhoneNumber', '[data-field="phone-number"]'], userData.phone);
                fillField(['#postal_code', '[data-field="zip-code"]'], userData.zipCode);
                fillField(['#tbDateOfBirth', '[data-field="date-of-birth"]'], userData.birthDate);
                
                // Activar cualquier evento necesario después de rellenar
                const inputs = document.querySelectorAll('#tbFirstName, #tbLastName, #tbEmail, #tbPhoneNumber, #postal_code, #tbDateOfBirth');
                inputs.forEach(input => {
                  if (input) {
                    // Disparar múltiples eventos para asegurar la compatibilidad
                    ['input', 'change', 'blur'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
              }, 1000);
              break;
              
            case 'auto_club':
              // Lógica específica para formulario de Auto Club
              console.log('Aplicando lógica específica para formulario de Auto Club');
              
              // Intentar rellenar los campos del formulario después de que cargue completamente
              setTimeout(function() {
                // Campos del formulario según los atributos name del HTML
                fillField(['input[name="first_name"]', '#first-name', 'input[id="first-name"]'], userData.firstName);
                fillField(['input[name="last_name"]', '#last-name', 'input[id="last-name"]'], userData.lastName);
                fillField(['input[name="user_address[address]"]', '#address', 'input[id="address"]'], userData.street);
                fillField(['input[name="zipcode"]', '#zipcode', 'input[id="zipcode"]'], userData.zipCode);
                fillField(['input[name="user_address[city]"]', '#city', 'input[id="city"]'], userData.city);
                fillField(['input[name="user_address[state]"]', '#state', 'input[id="state"]'], userData.state);
                fillField(['input[name="email"]', '#email', 'input[id="email"]'], userData.email);
                fillField(['input[name="phone"]', '#phone', 'input[id="phone"]'], userData.phone);
                
                // Activar eventos para asegurar que los campos se validen correctamente
                const autoClubInputs = document.querySelectorAll('.form__item input');
                autoClubInputs.forEach(input => {
                  if (input && input.value) {
                    console.log('Activando eventos para:', input.name || input.id);
                    ['input', 'change', 'blur', 'focus'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
                
                // Intentar hacer scroll al botón de continuar
                const continueButton = document.querySelector('button[type="submit"], .form__button, .btn-primary');
                if (continueButton) {
                  continueButton.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }, 2000); // Esperar 2 segundos para asegurar que el formulario está cargado
              break;

            case 'travel_club_add':
              // Lógica específica para formulario de Auto Club
              console.log('Aplicando lógica específica para formulario de Auto Club');
              
              // Intentar rellenar los campos del formulario después de que cargue completamente
              setTimeout(function() {
                // Campos del formulario según los atributos name del HTML
                fillField(['input[name="first_name"]', '#first-name', 'input[id="first-name"]'], userData.firstName);
                fillField(['input[name="last_name"]', '#last-name', 'input[id="last-name"]'], userData.lastName);
                fillField(['input[name="user_address[address]"]', '#address', 'input[id="address"]'], userData.street);
                fillField(['input[name="zipcode"]', '#zipcode', 'input[id="zipcode"]'], userData.zipCode);
                fillField(['input[name="user_address[city]"]', '#city', 'input[id="city"]'], userData.city);
                fillField(['input[name="user_address[state]"]', '#state', 'input[id="state"]'], userData.state);
                fillField(['input[name="email"]', '#email', 'input[id="email"]'], userData.email);
                fillField(['input[name="phone"]', '#phone', 'input[id="phone"]'], userData.phone);
                
                // Activar eventos para asegurar que los campos se validen correctamente
                const autoClubInputs = document.querySelectorAll('.form__item input');
                autoClubInputs.forEach(input => {
                  if (input && input.value) {
                    console.log('Activando eventos para:', input.name || input.id);
                    ['input', 'change', 'blur', 'focus'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
                
                // Intentar hacer scroll al botón de continuar
                const continueButton = document.querySelector('button[type="submit"], .form__button, .btn-primary');
                if (continueButton) {
                  continueButton.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }, 2000); // Esperar 2 segundos para asegurar que el formulario está cargado
              break;
              
            case 'homeowners':
              // Lógica específica para formulario de seguro de casa propia
              console.log('Aplicando lógica específica para formulario de seguro de casa propia');
              
              setTimeout(function() {
                // Campos comunes en formularios de seguro de propiedad
                fillField(['#zip', '#zipcode', '[name="zip"]', '[name="zipcode"]', '[id="zip"]', 'input[placeholder*="ZIP"]', 'input[placeholder*="Zip"]'], userData.zipCode);
                fillField(['#firstName', '#first_name', '[name="firstName"]', '[name="first_name"]', 'input[placeholder*="First"]'], userData.firstName);
                fillField(['#lastName', '#last_name', '[name="lastName"]', '[name="last_name"]', 'input[placeholder*="Last"]'], userData.lastName);
                fillField(['#email', '[name="email"]', 'input[type="email"]', 'input[placeholder*="Email"]'], userData.email);
                fillField(['#phone', '#phoneNumber', '[name="phone"]', '[name="phoneNumber"]', 'input[type="tel"]', 'input[placeholder*="Phone"]'], userData.phone);
                fillField(['#address', '#street', '[name="address"]', '[name="street"]', 'input[placeholder*="Address"]', 'input[placeholder*="Street"]'], userData.street);
                fillField(['#city', '[name="city"]', 'input[placeholder*="City"]'], userData.city);
                fillField(['#state', '[name="state"]', 'select[name="state"]'], userData.state);
                
                // Nuevo campo de fecha de nacimiento
                fillField(['#form_insurance_date_of_birth', '#date_of_birth', '[name="client[date_birth]"]', 'input[placeholder*="MM / DD / YYYY"]', 'input.only-date', 'input[autocomplete="bday"]'], userData.birthDate);
                
                // Activar eventos para validación
                const inputs = document.querySelectorAll('input, select');
                inputs.forEach(input => {
                  if (input && input.value) {
                    ['input', 'change', 'blur'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
                
                // Intentar hacer click en botón de continuar
                const nextButton = document.querySelector('button[type="submit"], .btn-primary, .next-button, button.continue');
                if (nextButton) {
                  nextButton.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }, 2000);
              break;
              
            case 'renters':
              // Lógica específica para formulario de seguro de inquilinos
              console.log('Aplicando lógica específica para formulario de seguro de inquilinos');
              
              setTimeout(function() {
                // Campos comunes en formularios de seguro de inquilinos
                fillField(['#zip', '#zipcode', '[name="zip"]', '[name="zipcode"]', '[id="zip"]', 'input[placeholder*="ZIP"]', 'input[placeholder*="Zip"]'], userData.zipCode);
                fillField(['#firstName', '#first_name', '[name="firstName"]', '[name="first_name"]', 'input[placeholder*="First"]'], userData.firstName);
                fillField(['#lastName', '#last_name', '[name="lastName"]', '[name="last_name"]', 'input[placeholder*="Last"]'], userData.lastName);
                fillField(['#email', '[name="email"]', 'input[type="email"]', 'input[placeholder*="Email"]'], userData.email);
                fillField(['#phone', '#phoneNumber', '[name="phone"]', '[name="phoneNumber"]', 'input[type="tel"]', 'input[placeholder*="Phone"]'], userData.phone);
                fillField(['#address', '#street', '[name="address"]', '[name="street"]', 'input[placeholder*="Address"]', 'input[placeholder*="Street"]'], userData.street);
                fillField(['#city', '[name="city"]', 'input[placeholder*="City"]'], userData.city);
                fillField(['#state', '[name="state"]', 'select[name="state"]'], userData.state);
                
                // Nuevo campo de fecha de nacimiento
                fillField(['#form_insurance_date_of_birth', '#date_of_birth', '[name="client[date_birth]"]', 'input[placeholder*="MM / DD / YYYY"]', 'input.only-date', 'input[autocomplete="bday"]'], userData.birthDate);
                
                // Activar eventos para validación
                const inputs = document.querySelectorAll('input, select');
                inputs.forEach(input => {
                  if (input && input.value) {
                    ['input', 'change', 'blur'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
                
                // Intentar hacer click en botón de continuar
                const nextButton = document.querySelector('button[type="submit"], .btn-primary, .next-button, button.continue');
                if (nextButton) {
                  nextButton.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }, 2000);
              break;
              
            case 'mobile_home':
              // Lógica específica para formulario de seguro de casa móvil
              console.log('Aplicando lógica específica para formulario de seguro de casa móvil');
              
              setTimeout(function() {
                // Campos comunes en formularios de seguro de casa móvil
                fillField(['#zip', '#zipcode', '[name="zip"]', '[name="zipcode"]', '[id="zip"]', 'input[placeholder*="ZIP"]', 'input[placeholder*="Zip"]'], userData.zipCode);
                fillField(['#firstName', '#first_name', '[name="firstName"]', '[name="first_name"]', 'input[placeholder*="First"]'], userData.firstName);
                fillField(['#lastName', '#last_name', '[name="lastName"]', '[name="last_name"]', 'input[placeholder*="Last"]'], userData.lastName);
                fillField(['#email', '[name="email"]', 'input[type="email"]', 'input[placeholder*="Email"]'], userData.email);
                fillField(['#phone', '#phoneNumber', '[name="phone"]', '[name="phoneNumber"]', 'input[type="tel"]', 'input[placeholder*="Phone"]'], userData.phone);
                fillField(['#address', '#street', '[name="address"]', '[name="street"]', 'input[placeholder*="Address"]', 'input[placeholder*="Street"]'], userData.street);
                fillField(['#city', '[name="city"]', 'input[placeholder*="City"]'], userData.city);
                fillField(['#state', '[name="state"]', 'select[name="state"]'], userData.state);
                
                // Activar eventos para validación
                const inputs = document.querySelectorAll('input, select');
                inputs.forEach(input => {
                  if (input && input.value) {
                    ['input', 'change', 'blur'].forEach(eventType => {
                      const event = new Event(eventType, { bubbles: true });
                      input.dispatchEvent(event);
                    });
                  }
                });
                
                // Intentar hacer click en botón de continuar
                const nextButton = document.querySelector('button[type="submit"], .btn-primary, .next-button, button.continue');
                if (nextButton) {
                  nextButton.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
              }, 2000);
              break;
            // Añadir más casos según sea necesario
          }
          
          console.log('Formulario prellenado con datos del usuario');
        }, 2000); // Esperar 2 segundos para asegurar que el DOM está cargado
      })();
    ''';

    // Inyectar el script en la página web
    await _controller.runJavaScript(script);
  }

  // Convierte un Map<String, String> a una representación de objeto JavaScript
  String _mapToJsObject(Map<String, String> map) {
    final entries = map.entries
        .map((e) => '"${e.key}": "${e.value.replaceAll('"', '\\"')}"')
        .join(',');
    return '{$entries}';
  }

  // Variable para rastrear si podemos navegar hacia atrás en el WebView
  bool _canGoBack = false;

  // Método para actualizar el estado de navegación hacia atrás
  Future<void> _updateBackNavigationState() async {
    final canGoBack = await _controller.canGoBack();
    if (canGoBack != _canGoBack && mounted) {
      setState(() {
        _canGoBack = canGoBack;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppTheme.white,
          ),
        ),
        backgroundColor: AppTheme.getBackgroundHeaderColor(context),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.white),
          onPressed: () async {
            // Si podemos navegar hacia atrás dentro del WebView, hacerlo
            if (await _controller.canGoBack()) {
              await _controller.goBack();
            } else {
              // Si no hay historial en el WebView, salir de la página
              if (context.mounted) Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.white),
            onPressed: () {
              _controller.reload();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) // Ahora _isLoading se basa en _isFormFillingComplete también
            Center(
              child: LoadingView(
                message: context.translate('common.loading'),
              ),
            ),
        ],
      ),
    );
  }
}
