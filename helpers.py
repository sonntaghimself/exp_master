from psychopy import gui
import datetime as dt
import os
import random
import pandas as pd
import sys

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
    myDlg.addField("Handedness:", choices=["right", "left", "ambidextrous"])
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
    files["blkdir"] = files["dirname"] + os.sep + "Block"
    files["resdir"] = files["dirname"] + os.sep + "Results"

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
            sw_in = sw_co = re_in = re_co = sw_easy = sw_hard = re_easy = re_hard = 0
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
                trl["difficulty"] = stim_blk[itrl][3]
                trl["cor_resp"] = stim_blk[itrl][4]
                trl["congruency"] = stim_blk[itrl][5]
                if itrl > 0:
                    if stim_blk[itrl][2] == stim_blk[itrl - 1][2]:
                        trl["transition"] = "repetition"
                        if trl["congruency"] == "incongruent":
                            re_in += 1
                        elif trl["congruency"] == "congruent":
                            re_co += 1
                        if trl["difficulty"] == "hard":
                            re_hard += 1
                        elif trl["difficulty"] == "easy":
                            re_easy += 1
                    else:
                        trl["transition"] = "switch"
                        if trl["congruency"] == "incongruent":
                            sw_in += 1
                        elif trl["congruency"] == "congruent":
                            sw_co += 1
                        if trl["difficulty"] == "hard":
                            sw_hard += 1
                        elif trl["difficulty"] == "easy":
                            sw_easy += 1
                else:
                    trl["transition"] = "first"

            # print(sw_co, sw_in, re_co, re_in)
            if (
                sw_co
                == sw_in
                == re_co
                == re_in
                == sw_easy
                == sw_hard
                == re_easy
                == re_hard
            ):
                break
            else:
                random.shuffle(stim_blk_old)
                stim_blk = [random.choice(stimuli)] + stim_blk_old

    return exp


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
                elif inst == "inst_2.txt":
                    txt_inst[os.path.splitext(inst)[0]] = f.read().format(
                        parameters["keys"][0].capitalize(),
                        parameters["keys"][1].capitalize(),
                    )
                elif inst == "inst_3.txt":
                    txt_inst[os.path.splitext(inst)[0]] = f.read().format(
                        parameters["cor_resp_dir"]["up"].capitalize(),
                        parameters["cor_col_resp"][
                            parameters["cor_resp_dir"]["up"]
                        ].capitalize(),
                    )
                elif inst == "inst_4.txt":
                    txt_inst[os.path.splitext(inst)[0]] = f.read().format(
                        parameters["cor_resp_dir"]["down"].capitalize(),
                        parameters["cor_col_resp"][
                            parameters["cor_resp_dir"]["down"]
                        ].capitalize(),
                    )
    return txt_inst


########################
#     Block Screen     #
########################
def block_screen(start, block, par, files):
    blk_num = block[0]["blk"]
    if start:
        with open(os.path.join(files["blkdir"], "BlkStart.txt"), "r") as f:
            BlkText = f.read().format(
                blk_num,
                par["exp_len"],
                par["cor_resp_dir"]["up"].capitalize(),
                par["cor_col_resp"][par["cor_resp_dir"]["up"]].capitalize(),
                par["cor_resp_dir"]["down"].capitalize(),
                par["cor_col_resp"][par["cor_resp_dir"]["down"]].capitalize(),
                blk_num,
            )
    else:
        num_trls = len(block)
        corr_blk = [x["corr"] for x in block]
        blk_per = round((corr_blk.count(1) / num_trls) * 100, 2)
        with open(os.path.join(files["blkdir"], "BlkEnd.txt"), "r") as f:
            BlkText = f.read().format(blk_num, par["exp_len"], blk_per)

    return BlkText


########################
#     Stimulus gen     #
########################
def StimNum(parameters):
    stim_num = None

    while True:
        if __name__ == "__main__":
            print(stim_num)
        if stim_num is None:
            stim_num = 2
        else:
            stim_num += 1

        if (
            int(parameters["proportions"]["color"]["hard"] * 100) % stim_num == 0
            and int(parameters["proportions"]["color"]["easy"] * 100) % stim_num == 0
            and int(parameters["proportions"]["direction"]["hard"] * 100) % stim_num
            == 0
            and int(parameters["proportions"]["direction"]["easy"] * 100) % stim_num
            == 0
            and int(parameters["proportions"]["distractor"] * 100) % stim_num == 0
        ):
            break

    return stim_num


if __name__ == "__main__":
    parameters = {
        "time": {"fix": 0.75, "feedback": 0.75, "iti": 0.5, "pres": 3},
        "keys": ["b", "z"],
        "start_key": "space",
        "dotsize": 50,
        "ndots": 400,
        "text_size": 35,
        "taskname": {"color": "Farbe", "direction": "Richtung"},
        "proportions": {
            "color": {"hard": 0.85, "easy": 0.70},
            "direction": {"hard": 0.85, "easy": 0.70},
            "distractor": 0.9,
        },
        "color": {"col_1": [-1, -1, 1], "col_2": [1, -1, -1]},
        "dir": {"up": 90, "down": 270},
        "dist_dir": {"up": 270, "down": 90},
        "colnames": {"col_1": "blau", "col_2": "rot"},
    }
    parameters["dist_col"] = {
        "col_1": parameters["color"]["col_2"],
        "col_2": parameters["color"]["col_1"],
    }

    stim_gen(parameters)
