#!/bin/sh
# convert.sh
# Contributed 2002 by Mark Miller (brandondoyle)
#
# A simple shell script (should be run on a cron)
# to convert each incoming resume and report back.  
# It's primarily a wrapper for Ant which takes care
# of setting the classpath and running Ant from each
# ./incoming/orc* directory.
# Ant isn't any good at loading classes itself.
#
# Should be run from ORC's root directory
#
########################################################

# You may need to change the following variables:
export SUPPORT_HOME="/home/groups/x/xm/xmlresume/resume-support"
#export SUPPORT_HOME="${HOME}/xmlresume/resume-support"
ANTCMD="${SUPPORT_HOME}/ant/ant"
JAVACMD=java

# Load user-specific configuration
if [ -f "${HOME}/.antrc" ]; then 
	. "${HOME}/.antrc"
fi


# Ant's ClassLoader is... frail.  We set the classpath
# outside of Ant, save ourselves some heartache.
cp="${SUPPORT_HOME}/fop.jar"
for jarfile in `ls -1 ${SUPPORT_HOME} | grep .jar`; do
	cp="${cp}:${SUPPORT_HOME}/${jarfile}"
done
for jarfile in `ls -1 ${SUPPORT_HOME}/ant/lib | grep .jar`; do
	cp="${cp}:${SUPPORT_HOME}/${jarfile}"
done
export CLASSPATH=$cp

echo "Using ClassPath: $CLASSPATH"

# Add option for the CLASSPATH
ANT_OPTS="${ANT_OPTS} -classpath ${LOCALCLASSPATH}"

cd incoming
for resume in `ls -1 | grep orc`; 
do
  cd $resume
	${ANTCMD} -debug -propertyfile user.props \
	-find build.xml dispatch >> ./out/antlog.txt
  sendmail -f'noreply@xmlresume.sourceforge.net' -t < reply.email
  cd ..
done