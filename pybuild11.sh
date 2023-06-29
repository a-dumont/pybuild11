#!/bin/sh

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
	printf 'cmake_minimum_required(VERSION 3.25)\n\n' >> $DIR/CMakeLists.txt
		
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

	printf 'add_compile_options(-Wall -O3 -march=native -MMD -MP)\n' >> $DIR/CMakeLists.txt

	printf 'if(CYGWIN)\n\t' >> $DIR/CMakeLists.txt
	printf 'add_compile_options(-DMS_WIN64 -D_hypot-hypot)\n\t' >> $DIR/CMakeLists.txt
	printf 'target_link_libraries(' >> $DIR/CMakeLists.txt
	printf "$NAME -" | awk '{printf tolower($0)}' >> $DIR/CMakeLists.txt
    printf 'DMS_WIN64 -D_hypot=hypot)\n\t' >> $DIR/CMakeLists.txt	
	printf 'target_link_libraries(' >> $DIR/CMakeLists.txt
	printf "$NAME -" | awk '{printf tolower($0)}' >> $DIR/CMakeLists.txt 
	printf 'L/c/Anaconda2/ -lpython27)\n' >> $DIR/CMakeLists.txt
	printf 'elseif(UNIX)\n\t' >> $DIR/CMakeLists.txt
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
	printf 'import os\n\nif os.name=="nt":\n\tos.add_dll_directories(' >> $NAME/__init__.py
	printf '"C:/cygwin64/usr/x86_64-w64-mingw32/sys-root/mingw/bin")\n\n'>>$NAME/__init__.py
	printf 'from .lib' >> $NAME/__init__.py
	printf "$NAME import *" | awk '{printf tolower($0)}' >> $NAME/__init__.py
	printf '\n\ndel os, lib' >> $NAME/__init__.py
	printf "$NAME" | awk '{printf tolower($0)}' >> $NAME/__init__.py
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
			cd $MODULE
			mkdir build && cd build
			cmake .. && cmake --build . && cmake --install .
			cd ../..
			exit 0
		else
			exit 0
		fi
elif [[ $ACTION = "2" ]]; then
		read -p "What is the name of the module? " MODULE
		read -p "How many submodules? " NUM
		if ! [ "$NUM" -ge 0 ] 2>/dev/null 
		then
			printf 'Invalid number. Exiting.\n'
		fi
		read -p "Do you want to create dir $PWD/$NAME and its content? (y/N): " ANS
		if [[ $ANS = "y"  ]] || [[ $ANS = "Y"  ]] || [[ $ANS = "yes"  ]]; then
			mkdir $MODULE
			cd $MODULE
			mkdir $MODULE
			ITER=1
			while [ $ITER -le $NUM  ]; do
				read -p "What is the name of submodule $ITER? " SUBMODULE
				create_code $PWD $SUBMODULE
				cd $MODULE
				add_python $SUBMODULE
				cd ..
				ITER=$((ITER+1))
			done
			cd ..
			#add_python $NAME
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


