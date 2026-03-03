import Foundation

#if canImport(AppKit)
extension SettingsController {
    static let embeddedSettingsFormHTML = #"""
<!doctype html>
<html>
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<style type="text/css">@import url("https://assets.mlcdn.com/fonts.css?version=1772539");</style>
<style type="text/css">
.ml-form-embedSubmitLoad { display: inline-block; width: 20px; height: 20px; }
.g-recaptcha { transform: scale(1); -webkit-transform: scale(1); transform-origin: 0 0; -webkit-transform-origin: 0 0; }
.sr-only { position: absolute; width: 1px; height: 1px; padding: 0; margin: -1px; overflow: hidden; clip: rect(0,0,0,0); border: 0; }
.ml-form-embedSubmitLoad:after { content: " "; display: block; width: 11px; height: 11px; margin: 1px; border-radius: 50%; border: 4px solid #fff; border-color: #ffffff #ffffff #ffffff transparent; animation: ml-form-embedSubmitLoad 1.2s linear infinite; }
@keyframes ml-form-embedSubmitLoad { 0% { transform: rotate(0deg);} 100% { transform: rotate(360deg);} }
#mlb2-37953616.ml-form-embedContainer { box-sizing: border-box; display: table; margin: 0 auto; position: static; width: 100% !important; }
#mlb2-37953616.ml-form-embedContainer h4,
#mlb2-37953616.ml-form-embedContainer p,
#mlb2-37953616.ml-form-embedContainer span,
#mlb2-37953616.ml-form-embedContainer button { text-transform: none !important; letter-spacing: normal !important; }
#mlb2-37953616.ml-form-embedContainer .ml-form-embedWrapper { background-color: #ffffff; border-width: 0px; border-color: transparent; border-radius: 4px; border-style: solid; box-sizing: border-box; display: inline-block !important; margin: 0; padding: 0; position: relative; }
#mlb2-37953616.ml-form-embedContainer .ml-form-embedWrapper.embedForm { max-width: 400px; width: 100%; }
#mlb2-37953616.ml-form-embedContainer .ml-form-align-center { text-align: center; }
#mlb2-37953616.ml-form-embedContainer .ml-form-embedWrapper .ml-form-embedBody,
#mlb2-37953616.ml-form-embedContainer .ml-form-embedWrapper .ml-form-successBody { padding: 20px 20px 0 20px; }
#mlb2-37953616.ml-form-embedContainer .ml-form-embedWrapper .ml-form-embedBody .ml-form-formContent { margin: 0 0 20px 0; width: 100%; }
#mlb2-37953616.ml-form-embedContainer .ml-form-embedWrapper .ml-form-embedBody .ml-form-fieldRow { margin: 0 0 10px 0; width: 100%; }
#mlb2-37953616.ml-form-embedContainer .ml-form-embedWrapper .ml-form-embedBody .ml-form-fieldRow input {
  background-color: #ffffff !important; color: #333333 !important; border-color: #cccccc; border-radius: 4px !important;
  border-style: solid !important; border-width: 1px !important; font-family: 'Open Sans', Arial, Helvetica, sans-serif;
  font-size: 13px !important; line-height: 21px !important; padding: 10px 10px !important; width: 100% !important; box-sizing: border-box !important;
}
#mlb2-37953616.ml-form-embedContainer .ml-form-embedWrapper .ml-form-embedBody .ml-form-embedSubmit { margin: 0 0 20px 0; float: left; width: 100%; }
#mlb2-37953616.ml-form-embedContainer .ml-form-embedWrapper .ml-form-embedBody .ml-form-embedSubmit button {
  background-color: #541071 !important; border: none !important; border-radius: 4px !important; color: #ffffff !important;
  cursor: pointer; font-family: 'Open Sans', Arial, Helvetica, sans-serif !important; font-size: 14px !important;
  line-height: 21px !important; padding: 10px !important; width: 100% !important; box-sizing: border-box !important;
}
#mlb2-37953616.ml-form-embedContainer .ml-form-embedWrapper .ml-form-embedBody .ml-form-embedSubmit button:hover { background-color: #333333 !important; }
</style>
</head>
<body>
<div id="mlb2-37953616" class="ml-form-embedContainer ml-subscribe-form ml-subscribe-form-37953616">
  <div class="ml-form-align-center ">
    <div class="ml-form-embedWrapper embedForm">
      <div class="ml-form-embedBody ml-form-embedBodyDefault row-form">
        <div class="ml-form-embedContent" style="margin-bottom: 0px;"></div>
        <form class="ml-block-form" action="https://assets.mailerlite.com/jsonp/712166/forms/180957358303741717/subscribe" data-code="" method="post" target="_blank">
          <div class="ml-form-formContent">
            <div class="ml-form-fieldRow ml-last-item">
              <div class="ml-field-group ml-field-email ml-validate-email ml-validate-required">
                <input aria-label="email" aria-required="true" type="email" class="form-control" data-inputmask="" name="fields[email]" placeholder="Email" autocomplete="email">
              </div>
            </div>
          </div>
          <input type="hidden" name="ml-submit" value="1">
          <div class="ml-form-embedSubmit">
            <button type="submit" class="primary">Subscribe for updates</button>
            <button disabled="disabled" style="display: none;" type="button" class="loading">
              <div class="ml-form-embedSubmitLoad"></div>
              <span class="sr-only">Loading...</span>
            </button>
          </div>
          <input type="hidden" name="anticsrf" value="true">
        </form>
      </div>
      <div class="ml-form-successBody row-success" style="display: none">
        <div class="ml-form-successContent">
          <h4>Thank you!</h4>
          <p>You have successfully joined our subscriber list.</p>
        </div>
      </div>
    </div>
  </div>
</div>
<script>
function ml_webform_success_37953616() {
  var $ = ml_jQuery || jQuery;
  $('.ml-subscribe-form-37953616 .row-success').show();
  $('.ml-subscribe-form-37953616 .row-form').hide();
}
</script>
<script src="https://groot.mailerlite.com/js/w/webforms.min.js?v95037e5bac78f29ed026832ca21a7c7b" type="text/javascript"></script>
<script>
fetch("https://assets.mailerlite.com/jsonp/712166/forms/180957358303741717/takel")
</script>
</body>
</html>
"""#
}
#endif
