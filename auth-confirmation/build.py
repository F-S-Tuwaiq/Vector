from pathlib import Path
import shutil

Path('dist').mkdir(exist_ok=True)
shutil.copyfile('index.html', 'dist/index.html')
shutil.copytree('assets', 'dist/assets', dirs_exist_ok=True)
