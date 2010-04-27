use inc::Module::Install;

name        'Jifty-Plugin-TemplateGraph';
version     '0.01';
requires    
    'Jifty' => 0,
    'GraphViz' => 0,
    'Template::Declare' => 0.29,
;

WriteAll;
&auto_install;
