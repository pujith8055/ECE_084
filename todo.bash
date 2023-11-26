#!/bin/bash

#Global variables
TODO_FILE=file
DONE_FILE=done
REMINDER=reminder

echo "Select an option:"
echo "1.add_task"
echo "2.get_tasks"
echo "3.remove_task"
echo "4.mark_task_as_done"
echo "5.clear_todo_list"
read -p "choose one option: " cases

# Add a new task to the todo list
function add_task() {
    NAME=$(zenity --entry --width 500 --title "log in" --text "Enter the user name")
    EMAIL=$(zenity --entry --width 500 --title "log in" --text "Enter Email address")
    DATE=$(zenity --calendar --title="Select a Date" --date-format %m-%d-%y --text="Select Date to pull the employee record.")
    local TASK
    TASK=$(zenity --entry --width 500 --title "add task" --text "Enter the task")

    # Add the task to the todo file
    echo "$TASK,$NAME,$EMAIL,$DATE" >> "$TODO_FILE"
}

# Get all tasks in the todo list
function get_tasks() {
    # No of lines in the file
    LINES=$(wc -l $TODO_FILE | cut -d ' ' -f 1)
    if [ "$LINES" -gt 0 ]; then
        # Get all tasks from the todo file
        echo "These are all the uncompleted tasks"
        cat $TODO_FILE
    else
        echo "There are no tasks"
    fi
}

# Remove a task from the todo list
function remove_task() {
    local WARNING
    TASK1=$(zenity --entry --width 500 --title "remove task" --text "Enter the task") 
    TODAY=$(date +%m-%d-%y)
    while IFS=',' read -r TASK NAME EMAIL DATE; do
        if [[ "$TASK1" == "$TASK" ]]; then
            if [[ "$TODAY" == "$DATE" ]] || [[ "$TODAY" < "$DATE" ]]; then
                WARNING=$(zenity --question --width 500 --title "Warning" --text "The task you are about to delete is not done or expired do you want to delete it?")
                RESPONSE=$?
                if [[ $RESPONSE == 0 ]]; then
                    # Remove the line from the todo file
                    sed -i "/$TASK/d" $TODO_FILE
                    zenity --info --width 500 --title "Completed" --text "Task is removed"
                else
                    zenity --info --width 500 --title "Completed" --text "Task is not removed"
                fi
            else
                sleep 0.01
            fi
        else
            sleep 0.01
        fi
    done < "$TODO_FILE"
}

# Mark a task as done
function mark_task_as_done() {
    local TASK
    TASK=$(zenity --entry --width 500 --title "mark task as done" --text "Enter the task")

    # Remove the task from the todo file
    sed -i "/$TASK/d" $TODO_FILE

    # Add the task to the done file
    echo "$TASK:done" >> $DONE_FILE
}

# Clear the todo list
function clear_todo_list() {
    # Empty the todo file
    local WARNING
    WARNING=$(zenity --question --width 500 --title "Warning" --text "This will clear your TODO list and it is irreversible. Do you want to continue?")
    RESPONSE=$?

    if [[ $RESPONSE == 0 ]]; then
        # Empth the todo file
        rm $TODO_FILE
        touch $TODO_FILE
        zenity --info --width 500 --title "Completed" --text "TODO file was cleared"

    elif [[ $RESPONSE == 1 ]]; then
        zenity --info --width 500 --title "Completed" --text "TODO file was not cleared"
    fi
}

# Reminder by email
function reminder(){
    TODAY=$(date +%m-%d-%y)
    while IFS=',' read -r TASK NAME EMAIL DATE; do

        # Task expired alert 
        if [[ "$TODAY" > "$DATE" ]]; then
                    mail -s "Todo list Expired" "$EMAIL" <<< "Dear $NAME,
    Your task \"$TASK\" has expired as of today $DATE.
Regards,
TODO LIST"
            echo "$TASK,$NAME,$EMAIL,$DATE" >> "$REMINDER"
            sed -i "/$TASK/d" $TODO_FILE

        # Today is the last date 
        elif [[ "$TODAY" == "$DATE" ]]; then
            mail -s "Todo list Reminder" "$EMAIL" <<< "Dear $NAME,
    This is a reminder for your task, \"$TASK\". Due date $DATE.
Regards,
TODO LIST"
        else
            sleep 0.01
        fi
    done < "$TODO_FILE"
}
reminder

# Parse the command line arguments
case "$cases" in
    1) add_task;;
    2) get_tasks;;
    3) remove_task;;
    4) mark_task_as_done;;
    5) clear_todo_list;;
    *) echo "Invalid option. Please use 1 - 5 to select an option.";;
esac
