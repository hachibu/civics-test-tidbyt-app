"""
civics_test.star — USCIS Civics Test for Tidbyt (Pixlet / Starlark)

Each render:
  1) Shows a waving American flag (shimmer sweep)
  2) Shows two randomized civics QUESTIONS (stable pair per day)
  3) After a configurable delay, reveals each ANSWER

Run locally:   pixlet serve civics_test.star
Render to web: pixlet render civics_test.star
Push:          pixlet push <DEVICE_ID> civics_test.webp --installation-id civics
"""

load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")

# ---------------------------------------------------------------------------
# Data: 128 USCIS civics questions with one concise, screen-friendly answer.
# (Questions with "answers will vary" / "see uscis.gov" use a short stand-in.)
# ---------------------------------------------------------------------------
QUESTIONS = [
    ("What is the form of government of the United States?", "Republic"),
    ("What is the supreme law of the land?", "The U.S. Constitution"),
    ("Name one thing the U.S. Constitution does.", "Forms the government"),
    ("What does \"We the People\" mean?", "People govern themselves"),
    ("How are changes made to the U.S. Constitution?", "Amendments"),
    ("What does the Bill of Rights protect?", "Basic rights of Americans"),
    ("How many amendments does the U.S. Constitution have?", "Twenty-seven (27)"),
    ("Why is the Declaration of Independence important?", "It says all people are created equal"),
    ("What founding document said the colonies were free from Britain?", "Declaration of Independence"),
    ("Name two important ideas from the Declaration and Constitution.", "Liberty and equality"),
    ("\"Life, Liberty, and the pursuit of Happiness\" are in what document?", "Declaration of Independence"),
    ("What is the economic system of the United States?", "Capitalism / free market"),
    ("What is the rule of law?", "No one is above the law"),
    ("Many documents influenced the Constitution. Name one.", "Declaration of Independence"),
    ("There are three branches of government. Why?", "So one part doesn't get too powerful"),
    ("Name the three branches of government.", "Legislative, executive, judicial"),
    ("The President is in charge of which branch?", "Executive branch"),
    ("What part of the federal government writes laws?", "Congress"),
    ("What are the two parts of the U.S. Congress?", "Senate and House"),
    ("Name one power of the U.S. Congress.", "Writes laws"),
    ("How many U.S. senators are there?", "One hundred (100)"),
    ("How long is a term for a U.S. senator?", "Six (6) years"),
    ("Who is one of your state's U.S. senators now?", "(Varies) your state's senator"),
    ("How many voting members are in the House of Representatives?", "Four hundred thirty-five (435)"),
    ("How long is a term for a member of the House?", "Two (2) years"),
    ("Why do representatives serve shorter terms than senators?", "To follow public opinion more closely"),
    ("How many senators does each state have?", "Two (2)"),
    ("Why does each state have two senators?", "Equal representation"),
    ("Name your U.S. representative.", "(Varies) your representative"),
    ("Who is the Speaker of the House now?", "See uscis.gov/citizenship/testupdates"),
    ("Who does a U.S. senator represent?", "People of their state"),
    ("Who elects U.S. senators?", "Citizens of their state"),
    ("Who does a member of the House represent?", "People of their district"),
    ("Who elects members of the House?", "Citizens of their district"),
    ("Some states have more representatives than others. Why?", "Because of the state's population"),
    ("The President is elected for how many years?", "Four (4) years"),
    ("The President can serve only two terms. Why?", "Because of the 22nd Amendment"),
    ("What is the name of the President now?", "See uscis.gov/citizenship/testupdates"),
    ("What is the name of the Vice President now?", "See uscis.gov/citizenship/testupdates"),
    ("If the president can no longer serve, who becomes president?", "The Vice President"),
    ("Name one power of the president.", "Signs bills into law"),
    ("Who is Commander in Chief of the U.S. military?", "The President"),
    ("Who signs bills to become laws?", "The President"),
    ("Who vetoes bills?", "The President"),
    ("Who appoints federal judges?", "The President"),
    ("The executive branch has many parts. Name one.", "The Cabinet"),
    ("What does the President's Cabinet do?", "Advises the President"),
    ("What are two Cabinet-level positions?", "Secretary of State; Attorney General"),
    ("Why is the Electoral College important?", "It decides who is elected president"),
    ("What is one part of the judicial branch?", "Supreme Court"),
    ("What does the judicial branch do?", "Reviews laws"),
    ("What is the highest court in the United States?", "Supreme Court"),
    ("How many seats are on the Supreme Court?", "Nine (9)"),
    ("How many Supreme Court justices are usually needed to decide a case?", "Five (5)"),
    ("How long do Supreme Court justices serve?", "For life"),
    ("Supreme Court justices serve for life. Why?", "To be independent of politics"),
    ("Who is the Chief Justice of the United States now?", "See uscis.gov/citizenship/testupdates"),
    ("Name one power only for the federal government.", "Print money / declare war"),
    ("Name one power only for the states.", "Provide schooling / police"),
    ("What is the purpose of the 10th Amendment?", "Powers not given to the U.S. belong to the states/people"),
    ("Who is the governor of your state now?", "(Varies) your governor"),
    ("What is the capital of your state?", "(Varies) your state capital"),
    ("Describe one amendment about who can vote.", "Citizens 18 and older can vote"),
    ("Who can vote, run for federal office, and serve on a jury?", "U.S. citizens"),
    ("What are three rights of everyone living in the U.S.?", "Speech, religion, assembly"),
    ("What do we show loyalty to in the Pledge of Allegiance?", "The United States / the flag"),
    ("Name two promises new citizens make in the Oath of Allegiance.", "Defend the Constitution; obey U.S. laws"),
    ("How can people become United States citizens?", "Be born in the U.S. or naturalize"),
    ("What are two examples of civic participation?", "Vote; join a political party"),
    ("What is one way Americans can serve their country?", "Vote; pay taxes; obey the law"),
    ("Why is it important to pay federal taxes?", "Required by law; civic duty"),
    ("Why should men 18-25 register for Selective Service?", "Required by law"),
    ("The colonists came to America for many reasons. Name one.", "Freedom; religious freedom"),
    ("Who lived in America before the Europeans arrived?", "American Indians / Native Americans"),
    ("What group of people was taken and sold as slaves?", "Africans"),
    ("What war did Americans fight to win independence from Britain?", "American Revolution"),
    ("Name one reason Americans declared independence from Britain.", "Taxation without representation"),
    ("Who wrote the Declaration of Independence?", "(Thomas) Jefferson"),
    ("When was the Declaration of Independence adopted?", "July 4, 1776"),
    ("Name one important event of the American Revolution.", "Declaration of Independence"),
    ("There were 13 original states. Name five.", "Virginia, New York, Georgia, Delaware, Massachusetts"),
    ("What founding document was written in 1787?", "The U.S. Constitution"),
    ("Name one writer of the Federalist Papers.", "(James) Madison / (Alexander) Hamilton / (John) Jay"),
    ("Why were the Federalist Papers important?", "They helped people support the Constitution"),
    ("Benjamin Franklin is famous for many things. Name one.", "U.S. diplomat; first Postmaster General"),
    ("George Washington is famous for many things. Name one.", "First president of the United States"),
    ("Thomas Jefferson is famous for many things. Name one.", "Wrote the Declaration of Independence"),
    ("James Madison is famous for many things. Name one.", "\"Father of the Constitution\""),
    ("Alexander Hamilton is famous for many things. Name one.", "First Secretary of the Treasury"),
    ("What territory did the U.S. buy from France in 1803?", "Louisiana Territory"),
    ("Name one war fought by the U.S. in the 1800s.", "Civil War"),
    ("Name the U.S. war between the North and the South.", "The Civil War"),
    ("The Civil War had many important events. Name one.", "Emancipation Proclamation"),
    ("Abraham Lincoln is famous for many things. Name one.", "Freed the slaves; 16th president"),
    ("What did the Emancipation Proclamation do?", "Freed the slaves in the Confederacy"),
    ("What U.S. war ended slavery?", "The Civil War"),
    ("What amendment made people born in the U.S. citizens?", "14th Amendment"),
    ("When did all men get the right to vote?", "With the 15th Amendment (1870)"),
    ("Name one leader of the women's rights movement in the 1800s.", "Susan B. Anthony"),
    ("Name one war fought by the U.S. in the 1900s.", "World War II"),
    ("Why did the U.S. enter World War I?", "Germany attacked U.S. ships"),
    ("When did all women get the right to vote?", "1920 (19th Amendment)"),
    ("What was the Great Depression?", "Longest economic recession in modern history"),
    ("When did the Great Depression start?", "The stock market crash of 1929"),
    ("Who was president during the Depression and WWII?", "(Franklin) Roosevelt"),
    ("Why did the U.S. enter World War II?", "Japan attacked Pearl Harbor"),
    ("Dwight Eisenhower is famous for many things. Name one.", "General in WWII; 34th president"),
    ("Who was the U.S. main rival during the Cold War?", "Soviet Union / USSR"),
    ("During the Cold War, what was one main U.S. concern?", "Communism"),
    ("Why did the U.S. enter the Korean War?", "To stop the spread of communism"),
    ("Why did the U.S. enter the Vietnam War?", "To stop the spread of communism"),
    ("What did the civil rights movement do?", "Fought to end racial discrimination"),
    ("Martin Luther King, Jr. is famous for many things. Name one.", "Fought for civil rights"),
    ("Why did the U.S. enter the Persian Gulf War?", "To force Iraq's military out of Kuwait"),
    ("What major event happened on September 11, 2001?", "Terrorists attacked the United States"),
    ("Name one U.S. military conflict after 9/11.", "War in Afghanistan (War on Terror)"),
    ("Name one American Indian tribe in the United States.", "Cherokee, Navajo, Sioux, Apache, Hopi"),
    ("Name one example of an American innovation.", "The light bulb"),
    ("What is the capital of the United States?", "Washington, D.C."),
    ("Where is the Statue of Liberty?", "New York Harbor (Liberty Island)"),
    ("Why does the flag have 13 stripes?", "There were 13 original colonies"),
    ("Why does the flag have 50 stars?", "One star for each of the 50 states"),
    ("What is the name of the national anthem?", "The Star-Spangled Banner"),
    ("\"E Pluribus Unum\" means what?", "Out of many, one"),
    ("What is Independence Day?", "A holiday celebrating U.S. independence"),
    ("Name three national U.S. holidays.", "Independence Day, Thanksgiving, Memorial Day"),
    ("What is Memorial Day?", "Honors soldiers who died in service"),
    ("What is Veterans Day?", "Honors people who served in the military"),
]

# ---------------------------------------------------------------------------
# Colors
# ---------------------------------------------------------------------------
RED = "#b22234"
WHITE = "#ffffff"
NAVY = "#3c3b6e"
BLACK = "#000000"
GOLD = "#ffd24a"
BLUE_LABEL = "#5a7dff"
GREY = "#888888"
SHIMMER = "#ffffff55"      # translucent white band
TRANSPARENT = "#00000000"

FRAME_MS = 100             # 10 fps
FPS = 1000 // FRAME_MS

# ---------------------------------------------------------------------------
# Daily randomized question pick (stable for the whole day)
# ---------------------------------------------------------------------------
def pick_two_for_today():
    ymd = int(time.now().format("20060102"))          # e.g. 20260619
    idx1 = (ymd * 1103515245 + 12345) % len(QUESTIONS)
    idx2 = (idx1 + 7) % len(QUESTIONS)               # offset to avoid adjacent Q
    return QUESTIONS[idx1], QUESTIONS[idx2]

# ---------------------------------------------------------------------------
# Flag rendering
# ---------------------------------------------------------------------------
def stripes():
    # 13 stripes whose heights sum to 32 px
    heights = [3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 3, 2, 2]
    rows = []
    for i in range(len(heights)):
        color = RED if i % 2 == 0 else WHITE
        rows.append(render.Box(width = 64, height = heights[i], color = color))
    return render.Column(children = rows)

def canton():
    # Blue field (~26x17) with a grid of white "stars"
    star_rows = []
    for _ in range(4):
        cells = []
        for _ in range(6):
            cells.append(render.Box(width = 1, height = 1, color = WHITE))
            cells.append(render.Box(width = 3, height = 1, color = NAVY))
        star_rows.append(render.Row(children = cells))
        star_rows.append(render.Box(width = 1, height = 3, color = NAVY))
    return render.Box(
        width = 26,
        height = 17,
        color = NAVY,
        child = render.Padding(pad = (2, 2, 0, 0), child = render.Column(children = star_rows)),
    )

def flag_base():
    return render.Stack(children = [stripes(), canton()])

def flag_frame(f):
    # A translucent band sweeps left->right to read as a "wave" / glint
    x = f * 6
    band = render.Row(children = [
        render.Box(width = x, height = 32, color = TRANSPARENT),
        render.Box(width = 6, height = 32, color = SHIMMER),
    ])
    return render.Stack(children = [flag_base(), band])

# ---------------------------------------------------------------------------
# Text screens
# ---------------------------------------------------------------------------
def question_screen(q):
    return render.Box(
        width = 64,
        height = 32,
        color = BLACK,
        child = render.Padding(
            pad = 1,
            child = render.Column(
                main_align = "center",
                cross_align = "center",
                children = [
                    render.Text("QUESTION", font = "tom-thumb", color = BLUE_LABEL),
                    render.Box(width = 1, height = 2),
                    render.Marquee(
                        height = 22,
                        scroll_direction = "vertical",
                        child = render.WrappedText(content = q, width = 62, font = "tom-thumb", color = WHITE, align = "center"),
                    ),
                ],
            ),
        ),
    )

def answer_screen(q, a, show_q):
    if show_q:
        marquee_child = render.Column(
            main_align = "center",
            cross_align = "center",
            children = [
                render.WrappedText(content = q, width = 62, font = "tom-thumb", color = GREY, align = "center"),
                render.Box(width = 1, height = 2),
                render.WrappedText(content = a, width = 62, font = "tom-thumb", color = GOLD, align = "center"),
            ],
        )
        marquee_height = 30
    else:
        marquee_child = render.WrappedText(content = a, width = 62, font = "tom-thumb", color = GOLD, align = "center")
        marquee_height = 28
    return render.Box(
        width = 64,
        height = 32,
        color = BLACK,
        child = render.Padding(
            pad = 1,
            child = render.Column(
                main_align = "center",
                cross_align = "center",
                children = [
                    render.Marquee(
                        height = marquee_height,
                        scroll_direction = "vertical",
                        child = marquee_child,
                    ),
                ],
            ),
        ),
    )

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main(config):
    delay_s = int(config.get("answer_delay") or "3")
    show_q = config.bool("show_question_with_answer", True)

    pair1, pair2 = pick_two_for_today()
    q1, a1 = pair1
    q2, a2 = pair2

    flag_frames = 14                  # ~1.4s flag intro
    q_hold = delay_s * FPS            # hold question for the configured delay
    a_hold = 6 * FPS                  # hold answer ~6s

    frames = []
    for f in range(flag_frames):
        frames.append(flag_frame(f))

    qs1 = question_screen(q1)
    for _ in range(q_hold):
        frames.append(qs1)

    ans1 = answer_screen(q1, a1, show_q)
    for _ in range(a_hold):
        frames.append(ans1)

    qs2 = question_screen(q2)
    for _ in range(q_hold):
        frames.append(qs2)

    ans2 = answer_screen(q2, a2, show_q)
    for _ in range(a_hold):
        frames.append(ans2)

    return render.Root(
        delay = FRAME_MS,
        show_full_animation = True,
        child = render.Animation(children = frames),
    )

# ---------------------------------------------------------------------------
# Schema (configuration in the Tidbyt app)
# ---------------------------------------------------------------------------
def get_schema():
    delay_options = [
        schema.Option(display = "2 seconds", value = "2"),
        schema.Option(display = "3 seconds", value = "3"),
        schema.Option(display = "5 seconds", value = "5"),
        schema.Option(display = "7 seconds", value = "7"),
        schema.Option(display = "10 seconds", value = "10"),
    ]
    return schema.Schema(
        version = "1",
        fields = [
            schema.Dropdown(
                id = "answer_delay",
                name = "Answer delay",
                desc = "How long to show the question before revealing the answer.",
                icon = "clock",
                default = "3",
                options = delay_options,
            ),
            schema.Toggle(
                id = "show_question_with_answer",
                name = "Keep question on answer screen",
                desc = "Show the question above the answer when it's revealed.",
                icon = "eye",
                default = True,
            ),
        ],
    )