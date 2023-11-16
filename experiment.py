"""
This experiment is to be a first draft of the experiment we will be implementing
for our Masters Thesis.

Congruency will be manipulated through the Congruency of movement direction and
color. participants have to respond to each with a key press.

A prime before the trial indicates which target dimension is relevant for the
following trial.

As DV, at this point, only Reaction time (and error commission) are recorded.

To start with, helpers will be imported and the participant information stored
in a seperate file (order will be randomized to assure anonymity)

new response keys: b & z

"""

from psychopy import visual, event, core
import datetime as dt
import pandas as pd
import helpers

########################
#   global variables   #
########################
parameters = {
    # have fix with task around it; 0.75 seconds, 0.75 error feedback
    "time": {"fix": 0.5, "feedback": 0.5, "iti": 0.5, "task": 1, "pres": 3},
    "keys": ["b", "z"],
    "start_key": "space",
    "dotsize": 50,
    "ndots": 400,
    "text_size": 35,
    "taskname": {"color": "Farbe", "direction": "Richtung"},
    "proportions": {
        "color": {"large": 0.85, "small": 0.70},
        "direction": {"large": 0.85, "small": 0.70},
    },
    "color": {"col_1": [-1, -1, 1], "col_2": [1, -1, -1]},
    # "dist_col": {"col_1": [1, 0, 0], "col_2": [0, 1, 0]},
    "dir": {"up": 90, "down": 270},
    # "dist_dir": {"up": 270, "down": 90},
    "colnames": {"col_1": "blau", "col_2": "rot"},
}

########################
#    vp information    #
########################
vp_info = helpers.gather_information()

# TODO: new number of trials
if vp_info["version"] == "full":
    parameters["num"] = {"nblks": 10, "pracblks": 2, "nprac": 24, "ntrls": 72}
elif vp_info["version"] == "test":
    parameters["num"] = {"nblks": 2, "pracblks": 0, "nprac": 8, "ntrls": 8}
# NOTE: since we have 4 stimuli (and two tasks), the #of trials has to be divisible by 8 (& >= 8)

########################
#       Stimuli        #
########################
dir = ["up", "down"]
col = ["col_1", "col_2"]
tsk = ["color", "direction"]
dif = ["easy", "hard"]
stimuli = [
    [direction, color, task, difficulty]
    for direction in dir
    for color in col
    for task in tsk
    for difficulty in dif
]

if vp_info["vp_num"] % 2 == 0:
    if vp_info["vp_num"] % 4 == 0:
        parameters["cor_resp_col"] = {"col_1": "l", "col_2": "s"}
        parameters["cor_resp_dir"] = {"up": "l", "down": "s"}
    else:
        parameters["cor_resp_col"] = {"col_1": "s", "col_2": "l"}
        parameters["cor_resp_dir"] = {"up": "s", "down": "l"}
elif vp_info["vp_num"] % 3 == 0:
    parameters["cor_resp_col"] = {"col_1": "l", "col_2": "s"}
    parameters["cor_resp_dir"] = {"up": "s", "down": "l"}
else:
    parameters["cor_resp_col"] = {"col_1": "s", "col_2": "l"}
    parameters["cor_resp_dir"] = {"up": "l", "down": "s"}

for stim in stimuli:
    if stim[2] == "color":
        stim.append(parameters["cor_resp_col"][stim[1]])
    elif stim[2] == "direction":
        stim.append(parameters["cor_resp_dir"][stim[0]])
    if parameters["cor_resp_dir"][stim[0]] == parameters["cor_resp_col"][stim[1]]:
        stim.append("congruent")
    else:
        stim.append("incongruent")

########################
#     import files     #
########################
files = helpers.my_files(vp_info)

# Storing demographics
helpers.demographics(vp_info, files)

########################
#      Trial Seq       #
########################
exp = helpers.randomisation(stimuli, vp_info, parameters, files)

########################
#     Instructions     #
########################
inst_text = helpers.read_instructions(files, parameters)

########################
#       Psychopy       #
########################
# win = visual.Window(size=(800, 800), color=(0, 0, 0), units="pix")
win = visual.Window(color=(0, 0, 0), fullscr=True, units="pix")
my_mouse = event.Mouse(visible=False)
frame_rate = win.getActualFrameRate(
    nIdentical=60, nMaxFrames=100, nWarmUpFrames=10, threshold=1
)

if frame_rate is None:
    frame_rate = 120

timer = core.Clock()
inst_stim = visual.TextStim(
    win,
    text=inst_text["inst_1"],
    alignText="center",
    # alignText="left",
    wrapWidth=(0.75 * win.size[0]),
    # bold=True,
    height=parameters["text_size"],
)
fb_stim = visual.TextStim(win, height=parameters["text_size"])
task_stim = visual.TextStim(win, height=parameters["text_size"])
fix_stim = visual.ShapeStim(
    win,
    lineWidth=2,
    lineColor="white",
    pos=(0, 0),
    vertices=((-10, 0), (10, 0), (0, 0), (0, 10), (0, -10)),
    closeShape=False,
)

# dots_stim = visual.DotStim(
#     win, dotSize=10, coherence=1, dotLife=-1, speed=1.5, units="pix",
#     fieldSize=[win.size[1]/4, win.size[1]/4],
#     nDots = int((parameters["ndots"]*parameters["proportions"]["color"]["small"])),
#     fieldShape = "circle"
# )

########################
#      Trial Loop      #
########################
for blk in exp:
    blk = [x for x in blk if x]  # making sure no faulty values are passed through

    if blk[0]["blk"] == 1:
        for inst in range(1, 4):
            inst_stim.text = inst_text["inst_" + str(inst)]
            inst_stim.draw()
            win.flip()
            event.waitKeys()
            # event.waitKeys(keyList=parameters["start_key"])

    for trl in blk:
        task_stim.text = parameters["taskname"][trl["task"]]
        for _ in range(int(parameters["time"]["fix"] * frame_rate)):
            fix_stim.draw()
            win.flip()
        for _ in range(int(parameters["time"]["task"] * frame_rate)):
            task_stim.draw()
            win.flip()

        dots_stim = visual.DotStim(
            win,
            dotSize=10,
            coherence=1,
            dotLife=-1,
            speed=1.5,
            units="pix",
            fieldSize=[win.size[1] / 4, win.size[1] / 4],
            nDots=int(
                (parameters["ndots"] * parameters["proportions"]["color"]["small"])
            ),
            fieldShape="circle",
        )

        dots_stim.color = parameters["color"][trl["color"]]
        dots_stim.dir = parameters["dir"][trl["direction"]]

        event.clearEvents()
        trl_complete = False

        win.callOnFlip(timer.reset)

        frames = 0
        slow = False

        while not trl_complete:
            dots_stim.draw()
            win.flip()
            frames += 1
            keys = []
            keys = event.getKeys()
            if keys:
                rt = timer.getTime()
                if trl["cor_resp"] in keys:
                    corr = 1
                    fb_stim.text = "RICHTIG"
                else:
                    corr = 0
                    fb_stim.text = "FALSCH"
                trl_complete = True

            elif frames >= int((parameters["time"]["pres"] * frame_rate)):
                rt = timer.getTime()
                fb_stim.text = "Too slow"
                trl_complete = True
                corr = 2
                slow = True

        if "escape" in keys:
            break

        for _ in range(int(parameters["time"]["feedback"] * frame_rate)):
            fb_stim.draw()
            win.flip()

        trl["date"] = dt.datetime.now().strftime("%d-%m-%Y-%H:%M:%S")
        trl["rt"] = rt
        trl["corr"] = corr

        for _ in range(int(parameters["time"]["iti"] * frame_rate)):
            win.flip()

    # generating end of block feeback
    blk_num = blk[0]["blk"]
    num_trls = len(blk)
    corr_blk = [x["corr"] for x in blk]
    blk_per = round((corr_blk.count(1) / num_trls) * 100, 2)

    fb_txt = "Block {} von {}, \n Richtig: {}%".format(blk_num, len(exp), blk_per)
    fb_txt = fb_txt + "\n\nUm fortzufahren, drücken sie die Leertaste."
    fb_stim.text = fb_txt
    fb_stim.draw()
    win.flip()
    event.waitKeys(keyList=[parameters["start_key"]])

    # blank screen for inter-trial-interval
    for _ in range(int(parameters["time"]["iti"] * frame_rate)):
        win.flip()

########################
#         Data         #
########################
tmp_data = [trial for data in exp for trial in data if trial]
dataDF = pd.DataFrame()
dataDF = dataDF.from_dict(tmp_data)
dataDF.to_csv(files["resfile"], header=True, index=False, sep=",", mode="w")


end_text = "The Experiment is done, thank you for participating"

end_text = end_text + "\n\n may the force be with you."

end_text = end_text + "\n\n press any key to end the experiment."

fb_stim.text = end_text
fb_stim.draw()
win.flip()
event.waitKeys()

# close window and quit
win.close()
core.quit()
