"""Isolated native engineering checks; HTTP responses are synthetic fixtures."""
import os,subprocess,tempfile,sys
from pathlib import Path
root=Path(__file__).resolve().parents[1]
engine=sys.argv[1]
subprocess.run([sys.executable,str(root/'scripts/build_save_adapter.py')],check=True)
for name,args,marker in [('import',['--editor','--import','--quit'],'DONE'),('domain',['--script','res://tests/council_test.gd'],'COUNCIL_FAILURES=0'),('export-safety',['--script','res://tests/export_safety_test.gd'],'COUNCIL EXPORT SAFETY PASS'),('ui',['--script','res://tests/ui_test.gd'],'UI_FAILURES=0'),('startup',['--quit-after','3'],'Godot Engine')]:
 with tempfile.TemporaryDirectory(prefix='council-verify-') as temp:
  env=os.environ.copy();env['XDG_DATA_HOME']=temp
  result=subprocess.run([engine,'--headless','--path',str(root/'native'),*args],env=env,text=True,encoding='utf-8',stdout=subprocess.PIPE,stderr=subprocess.STDOUT,timeout=35)
  (root/'docs/evidence'/('final-'+name+'.log')).write_text(result.stdout,encoding='utf-8')
  if result.returncode or marker not in result.stdout or 'SCRIPT ERROR' in result.stdout or 'ERROR:' in result.stdout:raise RuntimeError(name+': '+result.stdout)
  print(name.upper()+': PASS')
with tempfile.TemporaryDirectory(prefix='council-http-') as temp:
 env=os.environ.copy();env['XDG_DATA_HOME']=temp
 subprocess.run([sys.executable,str(root/'scripts/test_transport.py'),engine],env=env,check=True)
print('COUNCIL COMPLETE SOURCE SUITE PASS')
