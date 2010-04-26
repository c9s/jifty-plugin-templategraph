use inc::Module::Install;

name        'Jifty-Plugin-TemplateGraph';
version     '0.01';
requires    
    'Jifty' => '1.00105',
    'GraphViz' => 0
;

WriteAll;
&auto_install;
