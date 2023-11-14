from psychopy import gui
import datetime as dt
import os
import random
import pandas as pd

"""
in general, these are all the little worker functions to get my experiment
running.

The function check_data is going to be responsible for checking my data and
return a boolean that reflects whether the data format is correct or not.

The function gather_information is going to be the one responsible for
collecting the data; it will run recursively until check_data returns TRUE

the function my_files will open and load some current information and enable us
to save information in the current directory; it will take the vp_num as 
arguments and create a results file).

the function randomisation will take our trial list and randomise the
presentation order; then return the randomised trial list.

the function demographics will load the current dataframe with demographic
information, add the current information and save the file again in a randomised
order to guarantee anonymisation.
"""

gender = ["female", "male", "diverse", "prefer not to answer"]


########################
#      check_data      #
########################
def check_data(ok_data):
    """function to check whether the collected information is in the right
    format and plausible, returns a boolean"""
    check_passed = (
        isinstance(ok_data[0], int)
        and isinstance(ok_data[1], int)
        and (17 < ok_data[1] < 100)
        # and (ok_data[1] in gender) # don't need to be checked -> choices
    )
    return check_passed


########################
#  gather_information  #
########################
def gather_information():
    """this function gathers (demographic) information about the participants
    (including whether to run the test-version or not) and returns a dictionary
    containing the information.
    """
    myDlg = gui.Dlg(title="Participant Information")
    myDlg.addText("Subject info")
    myDlg.addField("VP Number:", initial=1)
    myDlg.addField("Age:", initial=18, tip="you have to be at least 18")
    myDlg.addField("Gender:", choices=gender)
    myDlg.addField("Handedness:", choices=["left", "right", "ambidextrous"])
    myDlg.addField("version", choices=["full", "test"])
    ok_data = myDlg.show()  # show dialog and wait for OK or Cancel
    check_passed = check_data(ok_data)
    if not check_passed:  # or if ok_data is not None
        return gather_information()
    else:
        return {
            "vp_num": ok_data[0],
            "age": ok_data[1],
            "gender": ok_data[2],
            "handedness": ok_data[3],
            "version": ok_data[4],
        }


########################
#      open files      #
########################
def my_files(vp_info):
    """this is the function that opens/creates necessary results files and
    stores the paths to those files in the variable files."""
    files = {"dirname": os.getcwd(), "vp_num": vp_info["vp_num"]}
    files["expname"] = os.path.basename(files["dirname"])
    files["date"] = dt.datetime.today().strftime("%d/%m/%Y")
    files["insdir"] = files["dirname"] + os.sep + "Instructions"
    files["resdir"] = files["dirname"] + os.sep + "Results"
    files["demo"] = files["dirname"] + os.sep + "Demographics"

    if not os.path.isdir(files["resdir"]):
        os.makedirs(files["resdir"])

    files["resfile"] = (
        files["resdir"]
        + os.sep
        + files["expname"]
        + "_"
        + str(vp_info["vp_num"])
        + ".res"
    )

    print(files["resfile"])

    if os.path.isfile(files["resfile"]):
        askUser = None
        while askUser not in ["y", "n"]:
            askUser = input("File exists! Overwrite? (y, n): ").lower()
        if askUser == "y":
            os.remove(files["resfile"])
        elif askUser == "n":
            sys.exit()
    return files


########################
#    randomisation     #
########################
def randomisation(stimuli, vp_info, parameters, files):
    all_blocks = parameters["num"]["pracblks"] + parameters["num"]["nblks"]

    if parameters["num"]["ntrls"] < len(stimuli):
        exp = [[{} for _ in range(len(stimuli) + 1)] for _ in range(all_blocks)]
    elif parameters["num"]["ntrls"] >= len(stimuli):
        exp = [
            [{} for _ in range((parameters["num"]["ntrls"]) + 1)]
            for _ in range(all_blocks)
        ]

    for iblk, blk in enumerate(exp):
        if iblk < parameters["num"]["pracblks"]:
            nstim = parameters["num"]["nprac"]
            practice = True
        else:
            nstim = parameters["num"]["ntrls"]
            practice = False

        if nstim <= len(stimuli):
            stim_blk = stimuli
        else:
            stim_blk = stimuli * int(nstim / len(stimuli))

        random.shuffle(stim_blk)
        stim_blk_old = stim_blk
        stim_blk = [random.choice(stimuli)] + stim_blk

        while True:
            sw_in = sw_co = re_in = re_co = 0
            for itrl, trl in enumerate(blk):
                if itrl >= len(stim_blk):
                    break

                for i in vp_info:
                    trl[i] = vp_info[i]

                trl["expname"] = files["expname"]
                trl["blk"] = iblk + 1
                trl["trl"] = itrl + 1
                trl["practice"] = practice
                trl["direction"] = stim_blk[itrl][0]
                trl["color"] = stim_blk[itrl][1]
                trl["task"] = stim_blk[itrl][2]
                trl["cor_resp"] = stim_blk[itrl][3]
                trl["congruency"] = stim_blk[itrl][4]
                if itrl > 0:
                    if stim_blk[itrl][2] == stim_blk[itrl - 1][2]:
                        trl["transition"] = "repetition"
                        if trl["congruency"] == "incongruent":
                            re_in += 1
                        elif trl["congruency"] == "congruent":
                            re_co += 1
                    else:
                        trl["transition"] = "switch"
                        if trl["congruency"] == "incongruent":
                            sw_in += 1
                        elif trl["congruency"] == "congruent":
                            sw_co += 1
                else:
                    trl["transition"] = "first"

            # print(sw_co, sw_in, re_co, re_in)
            if sw_co == sw_in == re_co == re_in:
                break
            else:
                random.shuffle(stim_blk_old)
                stim_blk = [random.choice(stimuli)] + stim_blk_old

    return exp


########################
#     demographics     #
########################
def demographics(vp_info, files):
    """this function takes care of storing the demographic data seperately from
    the other results and anonymises."""

    if not os.path.isdir(files["demo"]):
        os.makedirs(files["demo"])

    my_file_path = files["demo"] + os.sep + "demographics.csv"
    df = pd.DataFrame()

    if os.path.isfile(my_file_path):
        vp_info_cur = pd.read_csv(filepath_or_buffer=my_file_path, index_col=None)

        vp_info_cur = vp_info_cur.to_dict(orient="list")
        vp_info_cur["age"].append(vp_info["age"])
        vp_info_cur["gender"].append(vp_info["gender"])
        vp_info_cur["handedness"].append(vp_info["handedness"])
    else:
        vp_info_cur = {
            "age": [vp_info["age"]],
            "gender": [vp_info["gender"]],
            "handedness": [vp_info["handedness"]],
        }

    df = df.from_dict(vp_info_cur)
    df.to_csv(my_file_path, header=True, index=False, sep=",", mode="w")


########################
#     Instructions     #
########################
def read_instructions(files, parameters):
    txt_inst = {}
    for inst in os.listdir(files["insdir"]):
        if inst.endswith(".txt"):
            with open(os.path.join(files["insdir"], inst), "r") as f:
                if inst == "inst_1.txt":
                    txt_inst[os.path.splitext(inst)[0]] = f.read()
                if inst == "inst_2.txt":
                    txt_inst[os.path.splitext(inst)[0]] = f.read().format(
                        parameters["keys"][0].capitalize(),
                        parameters["keys"][1].capitalize(),
                    )
                if inst == "inst_3.txt":
                    txt_inst[os.path.splitext(inst)[0]] = f.read().format(
                        parameters["cor_resp_col"]["col_1"].capitalize(),
                        parameters["colnames"]["col_1"].capitalize(),
                        parameters["cor_resp_col"]["col_2"].capitalize(),
                        parameters["colnames"]["col_2"].capitalize(),
                        parameters["cor_resp_dir"]["up"].capitalize(),
                        parameters["cor_resp_dir"]["down"].capitalize(),
                    )
    return txt_inst
