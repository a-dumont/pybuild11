#!/bin/sh

cmake >> /dev/null
if ! [ $? -eq 0 ]; then
		printf 'CMake required'
		exit 0
fi

printf ' ___________________________________________ \n'
printf '|              _           _ _     _   _ _  |\n'
printf '|  _ __  _   _| |__  _   _(_) | __| | / / | |\n'
printf '| |  _ \| | | |  _ \| | | | | |/ _  | | | | |\n'
printf '| | |_) | |_| | |_) | |_| | | | (_| | | | | |\n'
printf '| | .__/ \__, |_.__/ \__,_|_|_|\__,_| |_|_| |\n'
printf '| |_|    |___/                              |\n'
printf '|___________________________________________|\n'

create_code()
{
	TARGET_DIR=$1
	NAME=$2

		
	DIR=$1/$NAME
	mkdir $DIR

	#Makes CMakeLists.txt
	printf 'cmake_minimum_required(VERSION 3.23)\n\n' >> $DIR/CMakeLists.txt
		
	printf "project($NAME VERSION 1.0.0)\n\n" >> $DIR/CMakeLists.txt
		
	printf 'option(BUILD_SHARED_LIBS "Build using shared libraries" ON)' >> $DIR/CMakeLists.txt
		
	printf '\n\nset(CMAKE_CXX_STANDARD 14)\n' >> $DIR/CMakeLists.txt
	printf 'set(CMAKE_CXX_STANDARD_REQUIRED True)\n\n' >> $DIR/CMakeLists.txt
	
	printf 'set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/obj)\n'>>$DIR/CMakeLists.txt
	printf 'set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/obj)\n'>>$DIR/CMakeLists.txt
	printf 'set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${PROJECT_SOURCE_DIR}/obj)\n'>>$DIR/CMakeLists.txt
		
	printf '\nif(CYGWIN)\n\tset(Python_EXECUTABLE "/c/Anaconda2/python")\n'>>$DIR/CMakeLists.txt
	printf 'endif()\n\n'>>$DIR/CMakeLists.txt
	printf 'find_package(Python COMPONENTS Interpreter REQUIRED)\n' >> $DIR/CMakeLists.txt
	printf 'execute_process(COMMAND ${Python_EXECUTABLE} -m pybind11 --'>> $DIR/CMakeLists.txt
	printf 'includes OUTPUT_VARIABLE PY_INCL)\n' >> $DIR/CMakeLists.txt
	printf 'string(REGEX REPLACE "-I" "" PY_INCL ${PY_INCL})\n' >> $DIR/CMakeLists.txt
	printf 'string(REGEX REPLACE "\\n" "" PY_INCL ${PY_INCL})\n' >> $DIR/CMakeLists.txt
	printf 'if(CYGWIN)\n\t' >> $DIR/CMakeLists.txt
	printf 'string(REGEX REPLACE "C\:" "/c" PY_INCL ${PY_INCL})\n' >> $DIR/CMakeLists.txt
	printf 'endif()\n'>>$DIR/CMakeLists.txt
	printf 'separate_arguments(PY_INCL)\n' >> $DIR/CMakeLists.txt
	printf 'include_directories(${PY_INCL})\n\n' >> $DIR/CMakeLists.txt
		
	printf 'file(GLOB SRC_FILES ${PROJECT_SOURCE_DIR}/src/*.cpp)\n\n' >> $DIR/CMakeLists.txt

	printf 'if(CYGWIN)\n\t' >> $DIR/CMakeLists.txt
	printf 'add_compile_options(-Wall -O3 -march=native -MMD -MP -DMS_WIN64 -D_hypot=hypot)\n' >> $DIR/CMakeLists.txt
	printf 'else()\n\t' >> $DIR/CMakeLists.txt
	printf 'add_compile_options(-Wall -O3 -march=native -MMD -MP)\n' >> $DIR/CMakeLists.txt
	printf 'endif()\n\n' >> $DIR/CMakeLists.txt

	printf 'add_library( ' >> $DIR/CMakeLists.txt
	printf "$NAME " | awk '{printf tolower($0)}' >> $DIR/CMakeLists.txt 
	printf '${SRC_FILES})\n\n' >> $DIR/CMakeLists.txt
		
	printf 'if(CYGWIN)\n\t' >> $DIR/CMakeLists.txt
	printf 'set_target_properties(' >> $DIR/CMakeLists.txt
	printf "$NAME " | awk '{printf tolower($0)}' >> $DIR/CMakeLists.txt 
	printf 'PROPERTIES SUFFIX \".pyd\")\n\t' >> $DIR/CMakeLists.txt
	printf 'set_target_properties(' >> $DIR/CMakeLists.txt
	printf "$NAME " | awk '{printf tolower($0)}' >> $DIR/CMakeLists.txt 
	printf 'PROPERTIES PREFIX \"lib\")\n' >> $DIR/CMakeLists.txt
	printf 'endif()\n\n'>>$DIR/CMakeLists.txt


	printf 'if(CYGWIN)\n\t' >> $DIR/CMakeLists.txt
	printf 'target_link_libraries(' >> $DIR/CMakeLists.txt
	printf "$NAME -" | awk '{printf tolower($0)}' >> $DIR/CMakeLists.txt
    	printf 'DMS_WIN64 -D_hypot=hypot)\n\t' >> $DIR/CMakeLists.txt	
	printf 'target_link_libraries(' >> $DIR/CMakeLists.txt
	printf "$NAME -" | awk '{printf tolower($0)}' >> $DIR/CMakeLists.txt 
	printf 'L/c/Anaconda2/ -lpython27)\n' >> $DIR/CMakeLists.txt
	printf 'else()\n\t' >> $DIR/CMakeLists.txt
	printf 'target_link_libraries(' >> $DIR/CMakeLists.txt
	printf "$NAME -" | awk '{printf tolower($0)}' >> $DIR/CMakeLists.txt
	printf 'lm)\n' >>$DIR/CMakeLists.txt
	printf 'endif()\n\n' >> $DIR/CMakeLists.txt
	printf 'install(TARGETS ' >> $DIR/CMakeLists.txt
	printf "$NAME " | awk '{printf tolower($0)}' >> $DIR/CMakeLists.txt 
	printf "DESTINATION \${PROJECT_SOURCE_DIR}/$NAME)" >> $DIR/CMakeLists.txt
		
	touch $DIR/README.md
	mkdir $DIR/includes
	touch $DIR/includes/dummy.txt
	mkdir $DIR/obj
	touch $DIR/obj/dummy.txt
	mkdir $DIR/src
	touch $DIR/src/"$NAME".tpp
	touch $DIR/src/"$NAME"_py.tpp

	#Makes .h file
	printf '#pragma once\n#include <iostream>\n\nvoid hello_world();' >> $DIR/src/$NAME.h
		
	#Makes .cpp file
	printf "#include \"$NAME.h\"\n\nvoid hello_world()\n" >> $DIR/src/$NAME.cpp
	printf "{\n\tstd::cout << \"Hello World!\" << std::endl;\n}" >> $DIR/src/$NAME.cpp

	#Makes _py.h file
	printf '#pragma once\n#include <pybind11/pybind11.h>\n'	>> $DIR/src/"$NAME"_py.h
	printf "#include \"$NAME.h\"\n\n" >> $DIR/src/"$NAME"_py.h
	printf 'namespace py = pybind11;\n' >> $DIR/src/"$NAME"_py.h
	printf 'using namespace pybind11::literals;' >> $DIR/src/"$NAME"_py.h
	
	#Makes _py.cpp file	
	printf "#include \"$NAME" >> $DIR/src/"$NAME"_py.cpp
	printf '_py.h\"\n\n' >> $DIR/src/"$NAME"_py.cpp
	printf 'void hello_world_py()\n{\n\thello_world();\n}\n\n' >> $DIR/src/"$NAME"_py.cpp
	printf 'void init_module(py::module &m)\n{\n\tm.def(' >> $DIR/src/"$NAME"_py.cpp
	printf '\"hello_world\", &hello_world_py, \"Hello World!\");' >> $DIR/src/"$NAME"_py.cpp
	printf '\n}\nPYBIND11_MODULE' >> $DIR/src/"$NAME"_py.cpp
	printf "(lib$NAME, m)" | awk '{printf tolower($0)}' >> $DIR/src/"$NAME"_py.cpp
	printf '\n{\n\tinit_module(m);\n}'  >> $DIR/src/"$NAME"_py.cpp
}

add_python()
{
	NAME=$1
	mkdir $NAME
	printf 'import os\n\nif os.name=="nt":\n\t' >> $NAME/__init__.py
	printf 'try:\n\t\t' >> $NAME/__init__.py
	printf 'os.add_dll_directories(' >> $NAME/__init__.py
	printf '"C:/cygwin64/usr/x86_64-w64-mingw32/sys-root/mingw/bin")\n\t'>>$NAME/__init__.py
	printf 'except:\n\t\t' >> $NAME/__init__.py
	printf 'os.environ["PATH"] = "C:/cygwin64/usr/x86_64-w64-mingw32/sys-root/mingw/bin"+";"'>>$NAME/__init__.py
	printf '+os.environ["PATH"]\n\n'>>$NAME/__init__.py
	printf 'from .lib' >> $NAME/__init__.py
	printf "$NAME import *" | awk '{printf tolower($0)}' >> $NAME/__init__.py
	printf '\n\ndel os, lib' >> $NAME/__init__.py
	printf "$NAME" | awk '{printf tolower($0)}' >> $NAME/__init__.py
}

create_setup_py()
{
	NAME=$1
	printf 'import setuptools\n\n' >> setup.py
	printf 'with open(\"README.md\",\"r\") as fh:\n\tlong_description = fh.read()\n\n' >> setup.py
	printf 'setuptools.setup(\n\t' >> setup.py
	printf "name=\"$NAME\",\n\t" >> setup.py
	printf 'version="1.0.0",\n\t' >> setup.py
	printf 'author="Generated by pybuild11",\n\t' >> setup.py
	printf 'author_email="blank@blank.blank",\n\t' >> setup.py
	printf 'long_description=long_description,\n\t' >> setup.py
	printf 'long_description_content_type="text/markdown",\n\t' >> setup.py
	printf 'classifiers=[\n\t\t' >> setup.py
	printf '"Programming Language :: Python :: 2-3",\n\t\t' >> setup.py
	printf '"License :: None",\n\t\t' >> setup.py
	printf '"Operating System :: OS Independent",\n\t],\n\t' >> setup.py
	printf 'install_requires=["numpy","pybind11"],\n\t' >> setup.py
	printf 'packages=setuptools.find_packages(),\n\t' >> setup.py
	printf 'include_package_data=True,\n\t' >> setup.py
	printf 'zip_safe=False\n)\n' >> setup.py
}

printf '\n\nWhat do you want to do?\n'
printf '(1) Create a single python module.\n'
printf '(2) Create a python module with multiple submodules.\n'
printf '(3) Exit.\n\n'

read -p 'Enter choice here (3): ' ACTION

if   [[ $ACTION = "1" ]]; then
		read -p "What is the name of the module? " MODULE
		read -p "Do you want to create dir $PWD/$NAME and its content? (y/N): " ANS
		if [[ $ANS = "y"  ]] || [[ $ANS = "Y"  ]] || [[ $ANS = "yes"  ]]; then
			create_code $PWD $MODULE
			cd $MODULE
			add_python $MODULE
			create_setup_py $MODULE
			printf "include $MODULE/lib" >> MANIFEST.in
			printf "$MODULE.*\n" | awk '{printf tolower($0)}' >> MANIFEST.in
			mkdir build && cd build
			cmake .. && cmake --build . && cmake --install .
			cd ../..
			printf 'To install the python package run: python setup.py install\n'
			exit 0
		else
			exit 0
		fi
elif [[ $ACTION = "2" ]]; then
		read -p "What is the name of the module? " MODULE
		read -p "How many submodules? " NUM
		if ! [ "$NUM" -ge 0 ]; then
			printf 'Invalid number. Exiting.\n'
			exit 1
		fi
		read -p "Do you want to create dir $PWD/$NAME and its content? (y/N): " ANS
		if [[ $ANS = "y"  ]] || [[ $ANS = "Y"  ]] || [[ $ANS = "yes"  ]]; then
			mkdir $MODULE
			cd $MODULE
			mkdir build

			touch README.md
			create_setup_py $MODULE
			printf 'cmake_minimum_required(VERSION 3.23)\n\n' >> CMakeLists.txt
			printf 'project(' >> CMakeLists.txt
			printf "$MODULE" | awk '{printf tolower($0)}' >> CMakeLists.txt
			printf ' VERSION 1.0.0)\n\n' >> CMakeLists.txt
			printf 'if(CYGWIN)\n\tset(Python_EXECUTABLE "/c/Anaconda2/python")\n' >> CMakeLists.txt
			printf 'endif()\n\n' >> CMakeLists.txt
			printf 'find_package(Python COMPONENTS Interpreter REQUIRED)\n\n' >> CMakeLists.txt

			mkdir $MODULE
			touch $MODULE/__init__.py
			ITER=1
			while [ $ITER -le $NUM  ]; do
				read -p "What is the name of submodule $ITER? " SUBMODULE
				create_code $PWD $SUBMODULE
				cd $MODULE
				add_python $SUBMODULE
				printf "import $MODULE.$SUBMODULE as $SUBMODULE\n\n" >> __init__.py

				cd ..
				printf "add_subdirectory($SUBMODULE)\n" >> CMakeLists.txt
				printf "install(DIRECTORY \${PROJECT_SOURCE_DIR}/$SUBMODULE/obj/\n\t" >> CMakeLists.txt
				printf "DESTINATION \${PROJECT_SOURCE_DIR}/$MODULE/$SUBMODULE\n\t" >> CMakeLists.txt
				printf "FILES_MATCHING PATTERN \"lib" >> CMakeLists.txt
				printf "$SUBMODULE" | awk '{printf tolower($0)}' >> CMakeLists.txt
				printf ".*\")\n\n" >> CMakeLists.txt

				printf "include $MODULE/$SUBMODULE/lib" >> MANIFEST.in
				printf "$SUBMODULE.*" | awk '{printf tolower($0)}' >> MANIFEST.in
				printf '\n' >> MANIFEST.in

				ITER=$((ITER+1))
			done
			cd build && cmake .. && cmake --build . && cmake --install .
			cd ../..
			printf 'To install the python package run: python setup.py install\n'
			exit 0
		else
			exit 0
		fi
elif [[ $ACTION = "3" ]]; then
		exit 0
elif [[ $ACTION = "" ]]; then
		exit 0
else
		printf 'Unrecognized input. Exiting.\n'
		exit 0
fi


