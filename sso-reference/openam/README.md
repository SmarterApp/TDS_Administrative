# Welcome to the OpenAM Project #

## About
This repository contains ForgeRock OpenAM source code and any scripts necessary to create an OpenAM Single Sign-On system for the Smarter Balanced Assessment Consortium (SBAC) / [SmarterApp](http://smarterapp.org) system..

## License
The code is released under the [CDDL1.0 license](http://opensource.org/licenses/CDDL-1.0).

## Support
Community support for the ForgeRock OpenAM server may be found here:  [ForgeRock - OpenAM](http://openam.forgerock.org).
Please direct all questions and/or comments to Scott Heger at [scott.heger@identityfusion.com](mailto:scott.heger@identityfusion.com)

## Content Overview
Files in the repository include the following:

* explodedWar - Unpacked custom OpenAM war files
* sbacInstaller 		              - SBAC OpenAM Installation Files
* source - Source code for OpenAM
* SBAC_SSO_Design-v1.10-03282014.pdf    - SBAC SSO Design Document
* sbacOpenAM-Installation-01152014.pdf - Installation instructions
* artifacts  - Artifacts used during the installation process
* installOpenAM.sh  - Bash script used to perform installation of OpenAM server
* removeOpenAM.sh  - Bash script used to remove OpenAM server
* tomcat.zip  - Pre-built version of Tomcat with custom OpenAM war 
* openamtools.zip  - Pre-built version of OpenAM Configurator and Admin Tools 
* templates - Template files used during the configuration of OpenAM

## UI Customizations ##
The EndUser pages as well as pages that handle password reset and the entering of security questions of OpenAM have been customized with the SBAC branding.  The full list of files under the deployed OpenAM war file that have been customized in this environment are:

*	saml2/jsp/idpSSOFederate.jsp
*	images/tools.png
*	images/favicon.ico
*	images/logo_sbac.jpg
*	images/errorandalert.png
*	images/greenCheck.png
*	images/successandalert.png
*	images/SBAC_IconSprite.png
*	css/sbac_style.css
*	css/new_style.css
*	auth/idm/EndUser.jsp
*	password/ui/PWResetSuccess.jsp
*	password/ui/PWResetQuestion.jsp
*	password/ui/PWResetUserValidation.jsp
*	sbac/SecurityQuestions.jsp
*	console/js/sbacLogin.js
*	console/js/sbacUMChangeUserPassword.js
*	console/js/sbacEndUser.js
*	console/js/jquery.base64.min.js
*	console/js/sbacUMUserPasswordResetOptions.js
*	console/idm/EndUser.jsp
*	console/user/UMChangeUserPassword.jsp
*	console/user/UMUserPasswordResetOptions.jsp
*	config/auth/default/services/sbac/html/user_inactive.jsp
*	config/auth/default/services/sbac/html/LDAP.xml
*	config/auth/default/services/sbac/html/Logout.jsp
*	config/auth/default/services/sbac/html/Login.jsp
*	config/auth/default/services/sbac/html/session_timeout.jsp
*	config/auth/default/services/sbac/html/login_failed_template.jsp
*	WEB-INF/lib/openam-federation-library-10.1.0-Xpress.jar
*	WEB-INF/lib/openam-auth-ldap-10.1.0-Xpress.jar
*	WEB-INF/classes/amConsole.properties
*	WEB-INF/classes/amPasswordReset.properties
*	WEB-INF/classes/amAccessControl.xml
*	WEB-INF/classes/amPasswordResetModuleMsgs_en.properties
*	WEB-INF/classes/amAuthUI.properties
*	WEB-INF/classes/amAuthUI_en.properties
*	WEB-INF/classes/amPasswordResetModuleMsgs.properties
*	WEB-INF/template/ldif/sfha/cts-add-schema.ldif
*	WEB-INF/template/ldif/sfha/cts-delete-schema.ldif
*	js/browser.js
*	js/modernizer.js
*	js/jquery.cookie.js

To modify these customized files for your own branding follow the instructions at: [http://docs.forgerock.org/en/openam/11.0.0/install-guide/index/chap-custom-ui.html](http://docs.forgerock.org/en/openam/11.0.0/install-guide/index/chap-custom-ui.html)