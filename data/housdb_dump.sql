--
-- PostgreSQL database dump
--

\restrict jKlO1l2ZAcjfcOOFmCDjtp8Y1YYLjJGCx1xE7kJxVLnqggd5etNzFFHRCf6klbm

-- Dumped from database version 14.22 (Ubuntu 14.22-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.22 (Ubuntu 14.22-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: circuits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.circuits (
    uid text NOT NULL,
    panel text NOT NULL,
    amps smallint NOT NULL,
    gfci boolean,
    afci boolean,
    voltage smallint,
    CONSTRAINT circuits_amps_check CHECK ((amps > 0))
);


--
-- Name: floors; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.floors (
    uid text NOT NULL
);


--
-- Name: interface_types; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.interface_types (
    short_name text NOT NULL
);


--
-- Name: interfaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.interfaces (
    space text NOT NULL,
    location_in_space text NOT NULL,
    circuit text,
    interface_type text NOT NULL,
    grounded boolean,
    notes text,
    rewired boolean,
    uid smallint NOT NULL,
    sits_within smallint
);


--
-- Name: spaces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.spaces (
    short_name text NOT NULL,
    floor text NOT NULL,
    description text
);


--
-- Name: interfaces_by_circuit; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.interfaces_by_circuit AS
 SELECT circuits.uid AS circuit,
    circuits.amps,
    COALESCE(bool_or(interfaces.rewired), false) AS has_rewired_interfaces,
    count(DISTINCT ((interfaces.space || interfaces.location_in_space) || interfaces.interface_type)) AS interface_count,
    count(DISTINCT ((interfaces.space || interfaces.location_in_space) || interfaces.interface_type)) FILTER (WHERE (NOT interfaces.grounded)) AS ungrounded_interfaces,
    count(DISTINCT ((interfaces.space || interfaces.location_in_space) || interfaces.interface_type)) FILTER (WHERE (interfaces.grounded IS NULL)) AS interfaces_grounding_unknown,
    array_agg(DISTINCT interfaces.space ORDER BY interfaces.space) FILTER (WHERE (interfaces.space IS NOT NULL)) AS spaces,
    array_agg(DISTINCT spaces.floor ORDER BY spaces.floor) AS floors
   FROM ((public.circuits
     LEFT JOIN public.interfaces ON ((interfaces.circuit = circuits.uid)))
     LEFT JOIN public.spaces ON ((interfaces.space = spaces.short_name)))
  GROUP BY circuits.uid, circuits.amps
  ORDER BY (count(DISTINCT ((interfaces.space || interfaces.location_in_space) || interfaces.interface_type))) DESC;


--
-- Name: interfaces_uid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.interfaces_uid_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: interfaces_uid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.interfaces_uid_seq OWNED BY public.interfaces.uid;


--
-- Name: panels; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.panels (
    short_name text NOT NULL,
    description text,
    notes text,
    circuit text
);


--
-- Name: wires; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wires (
    uid smallint NOT NULL,
    connects_from_breaker text,
    connects_from_interface smallint,
    connects_to_interface smallint NOT NULL,
    gauge smallint,
    conductors smallint DEFAULT 2 NOT NULL,
    ground boolean DEFAULT true,
    was_fished boolean,
    notes text,
    CONSTRAINT wires_check1 CHECK ((connects_from_interface <> connects_to_interface))
);


--
-- Name: wires_uid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wires_uid_seq
    AS smallint
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wires_uid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wires_uid_seq OWNED BY public.wires.uid;


--
-- Name: interfaces uid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interfaces ALTER COLUMN uid SET DEFAULT nextval('public.interfaces_uid_seq'::regclass);


--
-- Name: wires uid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wires ALTER COLUMN uid SET DEFAULT nextval('public.wires_uid_seq'::regclass);


--
-- Data for Name: circuits; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.circuits (uid, panel, amps, gfci, afci, voltage) FROM stdin;
1	subpanel	15	f	f	120
10	subpanel	15	f	f	120
3	subpanel	15	f	f	120
4	subpanel	15	f	f	120
5	subpanel	15	f	f	120
8	subpanel	15	f	f	120
9	subpanel	15	f	f	120
A25B	main	15	f	f	120
B20A	main	15	f	f	120
B22A	main	15	f	f	120
B4A	main	15	f	f	120
B28A/B30A	main	30	f	f	240
B8A/B10A	main	30	f	f	240
A21B/A23B	main	30	f	f	240
B12A/B14A	main	40	f	f	240
B16A/B18A	main	30	f	f	240
6	subpanel	15	f	f	120
2	subpanel	20	f	f	120
7	subpanel	20	f	f	120
11	subpanel	15	f	t	120
12	subpanel	15	f	t	120
B6A	main	15	f	t	120
A27B	main	15	f	t	120
B24A	main	15	f	t	120
B26A	main	15	f	t	120
A19B	main	15	f	t	120
\.


--
-- Data for Name: floors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.floors (uid) FROM stdin;
basement
downstairs
upstairs
attic
\.


--
-- Data for Name: interface_types; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.interface_types (short_name) FROM stdin;
switch
ceiling fixture
outlet
vent fan
ceiling fan
light fixture
wire
outlet (half)
switch (one of several)
junction box
gfci outlet
appliance
\.


--
-- Data for Name: interfaces; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.interfaces (space, location_in_space, circuit, interface_type, grounded, notes, rewired, uid, sits_within) FROM stdin;
kitchen	east wall of extension, north of counters	8	outlet	t	plug updated, wiring looks modern	f	1	\N
utility room	east wall upper	B4A	switch	t	furnace safety off switch	f	3	\N
basement landing	south wall	B26A	outlet	t	in formerly water damaged area; junction box replaced	t	5	\N
laundry	ceiling	B26A	ceiling fixture	t	bare-bulb fixture replaced with newer bare-bulb fixture	f	6	\N
living room (south)	northeast wall 	A25B	outlet	t	\N	f	7	\N
kitchen	dishwasher	3	wire	t	\N	f	8	\N
basement main room	south wall, north of closet (bottom switch)	B20A	switch	\N	controls half of overhead lights	f	11	\N
basement main room	south wall, north of closet (top switch)	B22A	switch	\N	controls half of overhead lights	f	12	\N
sewing room	east wall (north)	B6A	outlet	t	new!	t	14	\N
office	ceiling	A27B	ceiling fixture	t	new junction and fixture installed	t	15	\N
laundry	west wall	B26A	outlet	t	should be GFCI!	f	16	\N
basement main room	north wall west of door	4	outlet	t	chest freezer	f	17	\N
kitchen	south of sink, over counter	6	outlet	t	should be GFCI	f	18	\N
kitchen	north of sink, over counter	8	outlet	t	should be GFCI	f	19	\N
front porch	ceiling	A27B	light fixture	t	newly replaced; controlled by switch inside door	t	20	\N
basement back room (west)	east wall	10	outlet	t	\N	f	22	\N
bedroom	east wall behind dresser	5	outlet	t	runs through vent	f	23	\N
downstairs landing	west wall by front door, north switch	A27B	switch (one of several)	t	3-way switch; controls ceiling light in upstairs landing	t	24	\N
kitchen	south of stove, over counter	8	outlet	t	\N	f	25	\N
basement main room	west wall (north)	B22A	outlet	t	\N	f	26	\N
office	east wall	A27B	outlet	t	end of the circuit	f	27	\N
back yard	over bay window	8	light fixture	t	has not worked yet; suspect it's activated by the third switch inside the door. Suspect circuit 8	f	28	\N
basement back room (east)	south wall	8	switch	t	\N	f	30	\N
basement back room (west)	east wall near entrance	1	switch	t	\N	f	32	\N
basement main room	west wall (south)	B22A	outlet	t	replaced outlet 2025-11-23; ground wired to box; too short to wire to plug, but connection to box appears to be grounding it	f	33	\N
kitchen	ceiling, south over main kitchen	11	light fixture	t	\N	t	36	\N
utility room	ceiling	A19B	junction box	t	new box. Added here on the way to outlets in the living room to potentially power other stuff in utility room later	t	38	\N
bedroom	center of ceiling	12	ceiling fixture	t	\N	t	39	\N
upstairs landing	ceiling	A27B	ceiling fixture	t	switched at top and bottom of stairs	t	41	\N
living room (north)	southwest baseboard	A19B	outlet	t	Formerly K+T, fully replaced on new circuit; this one is powered from the outlet a few inches south of it	t	42	\N
basement back room (west)	north wall	10	outlet	t	within water damage zone	f	43	\N
basement back room (west)	east wall near entrance	1	light fixture	\N	\N	f	44	\N
basement back room (east)	below panel	1	outlet	t	\N	f	45	\N
basement back room (west)	south wall	10	outlet	t	within water damage zone	f	46	\N
laundry	east wall	B28A/B30A	outlet	t	\N	f	47	\N
basement main room	ceiling (west wide)	B22A	light fixture	\N	west-side cluster of embedded ceiling lights	f	48	\N
basement main room	ceiling (east side)	B20A	light fixture	\N	east-side cluster of embedded ceiling lights	f	49	\N
basement main room	south wall, north of cedar closet	B20A	outlet	t	\N	f	50	\N
basement main room	north wall east of door	8	outlet	t	\N	f	51	\N
kitchen	east wall south of counter, behind fridge	9	outlet	t	\N	f	52	\N
living room (north)	east wall	5	outlet	t	runs through vent	f	53	\N
kitchen	north wall below bay window	8	outlet	t	\N	f	55	\N
utility room	ceiling	B22A	ceiling fixture	t	\N	f	56	\N
back yard	on south side (north wall of house)	8	outlet	t	needs GFCI protection and weatherproof cover	f	57	\N
kitchen	north of stove (top plug)	6	outlet (half)	t	\N	f	58	\N
kitchen	behind stove	B16A/B18A	outlet	t	big stove outlet	f	59	\N
back porch	over the door	8	light fixture	\N	controlled by switch inside door	f	60	\N
upstairs bathroom	south wall	11	gfci outlet	t	newly replaced	t	61	\N
basement stairs	east side of middle landing	B24A	switch	t	double switch; controls light at bottom of stairs and light outside side door	f	63	\N
kitchen	north of stove (bottom plug)	10	outlet (half)	t	\N	f	65	\N
basement landing	ceiling	B24A	light fixture	t	newly installed junction box replaced previous rat's nest	t	66	\N
side walkway	west wall over door	B24A	light fixture	t	ground wire is not actually connected to fixture ground though	f	67	\N
kitchen	ceiling, north over extension	8	light fixture	t	fixture replaced with chandelier	f	68	\N
basement landing	south wall	B26A	switch	t	controls laundry room lights	t	70	\N
sewing room	east wall (south)	B6A	outlet	t	new!	t	72	\N
basement bathroom	ceiling of shower	B26A	ceiling fixture	t	replaced with ill-fitting LED fixture. Has it's own little junction box up there.	t	4	\N
basement landing	north wall	A19B	light fixture	f	formerly powered by ungrounded lamp wire from cedar closet; modern wiring now	t	69	\N
office	north wall	A27B	outlet	t	new wire comes from attic, old grounded wire extends south to outlet on east wall	t	31	\N
basement bathroom	ceiling	B26A	ceiling fixture	t	replaced with new simple fixture	t	54	\N
basement landing	west wall	B26A	switch	t	controls bathroom lights and fan	t	71	\N
office	west wall	A27B	switch	t	passes power on to the attic and thence to the rest of the outlets	t	64	\N
sewing room	ceiling	B6A	ceiling fixture	\N	new	t	13	\N
living room (north)	east wall near door to kitchen	11	switch	t	new junction box installed	t	35	\N
kitchen	west wall, south side	11	switch	t	controls ceiling light	t	37	\N
upstairs landing	north wall outside bathroom (west switch)	12	switch (one of several)	t	3-way switch; controls downstairs landing light	t	40	\N
downstairs landing	west wall by front door, middle switch	12	switch (one of several)	t	3-way switch; controls ceiling light downstairs landing	t	21	\N
downstairs landing	ceiling	12	ceiling fixture	t	controlled by 2 3-way switches at top and bottom of stairs	t	10	\N
living room (north)	ceiling	11	light fixture	t	formerly a ceiling fan. Box is secured only to (reinforced) plaster	t	34	\N
basement main room	ceiling (west side)	B22A	junction box	t	big hot sloppy mess, but at least I could disconnect some K+T wires from it	\N	73	\N
basement main room	ceiling (east side)	B20A	junction box	t	big hot sloppy mess	\N	74	\N
kitchen	west wall near door to back porch	8	switch	t	triple switch, one controls outside light, one the light in the extension, one I think controls the flood light over the back yard	f	76	\N
upstairs bathroom	over mirror	11	light fixture	t	\N	f	77	\N
upstairs bathroom	ceiling	11	light fixture	\N	wired together with vent fan - same switch	f	78	\N
upstairs landing	north wall, top of stairs	11	outlet	t	newly installed	t	79	\N
utility room	near door	B8A/B10A	appliance	t	water heater	f	80	\N
upstairs bathroom	top of north wall	11	vent fan	t	wired together with ceiling light - same switch; came that way	f	81	\N
attic	northish, above the fluff	12	outlet	t	new! Unsure what the code is for spaces like this...	t	82	\N
utility room	east wall lower	B22A	switch	t	\N	f	83	\N
living room (south)	southeast wall	A27B	outlet	t	newly upgraded!	t	84	\N
basement back room (west)	west wall	10	outlet	t	within water damage zone	f	85	\N
basement back room (west)	north wall	10	wire	\N	wire coming out of wall; does not seem to be live	f	86	\N
front yard	west of porch	A21B/A23B	appliance	t	air conditioner	f	87	\N
sewing room	east wall	B6A	switch	t	rewired, moved from behind door	t	88	\N
kitchen	over stove	10	vent fan	t	also has lights	f	89	\N
cedar closet	above door	B22A	light fixture	\N	not up to code as a bare-bulb fixture	f	90	\N
basement landing	north wall	B22A	outlet	t	used by aquarium	f	92	\N
basement back room (east)	south wall	8	outlet	t	\N	f	93	\N
basement back room (east)	north wall	1	outlet	t	\N	f	94	\N
basement back room (east)	south wall	8	light fixture	\N	\N	f	95	\N
downstairs landing	west wall by front door, south switch	A27B	switch (one of several)	t	controls front porch light	t	99	\N
living room (south)	northwest baseboard	A19B	outlet	t	formerly K+t, fully replaced and rewired. Powered from junction box in the utility room ceiling	t	100	\N
basement stairs	top of stairs, west wall	A19B	switch	t	new switch box; formerly controlled aquarium plug; k + t wires and sketchy-ass junction box completely removed	t	2	\N
basement bathroom	ceiling	B26A	vent fan	t	new	t	101	\N
basement bathroom	above mirror	\N	wire	t	dangling wire, not connected. Is inserted in junction box with powered switches though	t	91	\N
attic	north side on top of horizontal board	12	junction box	t	serves as base camp for attic power	t	103	\N
office	west wall	A27B	outlet	t	passes power on to switch, above	t	75	\N
basement landing	south wall (upper)	B26A	junction box	t	is just a join between and older and a newer wire	t	105	\N
basement landing	south wall (lower, next to switch)	B26A	junction box	t	preexisting junction box	t	104	\N
living room (south)	southeast wall	A27B	junction box	t	new; added later to split power off from this circuit	t	106	\N
upstairs landing	north wall outside bathroom (east switch)	A27B	switch (one of several)	t	3-way switch; controls ceiling light in upstairs landing	t	97	\N
bedroom	east wall by door	12	switch	t	replaced with new reno box. Has had plaster repaired and painted	t	96	\N
upstairs bathroom	south wall (east switch); middle switch	11	switch (one of several)	t	controls small recessed ceiling light and vent fan	f	62	\N
kitchen	ceiling, in the big hole	11	junction box	t	first stopping point for this circuit; basecamp	t	107	\N
upstairs bathroom	south wall (west switch)	11	switch (one of several)	t	controls lights over mirror	f	108	\N
\.


--
-- Data for Name: panels; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.panels (short_name, description, notes, circuit) FROM stdin;
main	\N	\N	\N
subpanel	\N	\N	B12A/B14A
\.


--
-- Data for Name: spaces; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.spaces (short_name, floor, description) FROM stdin;
office	upstairs	blue room
sewing room	upstairs	orange room
bedroom	upstairs	green room
upstairs bathroom	upstairs	\N
basement bathroom	basement	\N
laundry	basement	\N
kitchen	downstairs	\N
living room (north)	downstairs	\N
living room (south)	downstairs	\N
coat closet	downstairs	\N
front porch	downstairs	I guess this is a "room" now
basement landing	basement	shared tiled area at base of stairs
basement stairs	basement	\N
upstairs landing	upstairs	"hallway"-like object
downstairs landing	downstairs	another hallway-like object
back porch	downstairs	\N
back yard	downstairs	\N
basement back room (east)	basement	the smaller one with the panel
basement back room (west)	basement	the larger one with the water damage
basement main room	basement	the part with the laminate flooring
cedar closet	basement	the whole closet really, including the antecloset
side walkway	downstairs	outside space accessible from side door
utility room	basement	has furnace, etc
front yard	downstairs	does not include the porch
attic	attic	\N
\.


--
-- Data for Name: wires; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.wires (uid, connects_from_breaker, connects_from_interface, connects_to_interface, gauge, conductors, ground, was_fished, notes) FROM stdin;
1	\N	38	2	14	2	t	\N	\N
2	\N	2	69	14	2	t	\N	switched
3	\N	71	101	14	2	t	\N	\N
4	\N	71	91	14	2	t	\N	\N
5	\N	71	54	14	2	t	\N	\N
6	\N	71	4	14	2	t	\N	\N
7	\N	5	71	14	2	t	\N	\N
9	\N	64	15	14	2	t	t	fished through wall to switch from the attic
8	\N	31	27	14	2	t	\N	modern romex, but original to the house
10	\N	103	82	14	2	t	f	short run, above the insulation in the attic; held with staples
11	\N	100	42	14	2	t	f	short open run within wall; less than a foot
12	\N	38	100	14	2	t	t	\N
13	A19B	\N	38	14	2	t	t	\N
14	\N	75	64	14	2	t	t	is a bit too long. Did this early when I was nervous about cutting too short
15	\N	64	31	14	2	t	t	runs through attic. I don't think I stopped it in a junction box up there. Fished by pulling through with the old romex wire that ran down from the attic
16	\N	96	39	14	2	t	t	runs in attic and was fished down wall to preexisting hole
17	\N	88	13	14	2	t	t	runs in attic; was fished down the wall
18	\N	99	20	14	2	t	t	fished through preexisting hole in the brick wall, and through a joist or two. Stapled where I was able to reach
21	\N	105	6	14	2	t	\N	OLDER WIRE; cloth covered romex
22	\N	104	5	14	2	t	f	older, but modern romex
23	\N	104	16	14	2	t	t	older, but modern romex
24	\N	5	71	14	2	t	t	new, 2025
25	B26A	\N	104	14	2	t	t	cloth-bound romex; pretty sure this is the connection but can't see where it actually runs over the doorway
20	\N	104	70	14	2	t	f	short run
19	\N	70	105	12	2	t	\N	\N
26	\N	35	34	14	2	t	t	fished both ways from hole in kitchen ceiling
27	\N	37	36	14	2	t	t	fished both ways from hole in kitchen ceiling
28	\N	79	61	14	2	t	t	fairly short run; pulled off lath to expose much of this
29	\N	72	14	14	2	t	f	just runs through two studs
30	B6A	\N	72	14	2	t	t	a long run
31	\N	14	88	14	2	t	t	makes an unnecessarily long run up and into the attic so both ends could be fished downward rather than drilling through studs and removing more plaster
32	A27B	\N	106	14	2	t	t	\N
34	\N	106	84	14	2	t	t	\N
35	\N	24	97	14	3	t	t	3-way wire powering upstairs landing light
36	\N	40	21	14	3	t	t	3-way wire
37	\N	21	10	14	2	t	t	\N
38	\N	97	41	14	2	t	t	runs for a stretch in the attic
39	12	\N	103	14	2	t	t	fished this with Rick's help
40	\N	103	82	14	2	t	f	out in the open in the attic; stapled
41	\N	103	40	14	2	t	t	fished basically straight down I think
42	\N	103	96	14	2	t	t	runs a little ways in the attic and was then fished down to the switch
43	11	\N	107	14	2	t	t	fished this with Rick's help
44	\N	107	35	14	2	t	t	runs through 1 joist, then down through the wall
45	\N	35	37	14	2	t	f	short run within same joist space - less than a foot
46	\N	107	79	14	2	t	t	\N
47	\N	61	62	14	2	t	\N	internal within junction box
48	\N	61	108	14	2	t	\N	internal within junction box
49	\N	108	77	14	2	t	\N	wire original to house; pretty sure it looked like modernish romex from end in junction box
50	\N	62	78	14	2	t	\N	wire original to house; pretty sure it looked like modernish romex from end in junction box; but I actually can't recall now whether it's one or two wires entering the box? it may split somewhere I haven't seen yet. 
51	\N	62	81	14	2	t	\N	wire original to house; pretty sure it looked like modernish romex from end in junction box; but I actually can't recall now whether it's one or two wires entering the box? it may split somewhere I haven't seen yet. 
52	\N	84	75	14	2	t	t	\N
53	\N	106	99	14	2	t	t	duplicate of 33. Power is supplied to both interfaces within junction by one actual wire
33	\N	106	24	14	2	t	t	duplicate of 53. Power is supplied to both interfaces within junction by one actual wire
\.


--
-- Name: interfaces_uid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.interfaces_uid_seq', 108, true);


--
-- Name: wires_uid_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.wires_uid_seq', 53, true);


--
-- Name: circuits circuits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circuits
    ADD CONSTRAINT circuits_pkey PRIMARY KEY (uid);


--
-- Name: floors floors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT floors_pkey PRIMARY KEY (uid);


--
-- Name: interface_types interface_types_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interface_types
    ADD CONSTRAINT interface_types_pkey PRIMARY KEY (short_name);


--
-- Name: interfaces interfaces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT interfaces_pkey PRIMARY KEY (space, location_in_space, interface_type);


--
-- Name: panels panels_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.panels
    ADD CONSTRAINT panels_pkey PRIMARY KEY (short_name);


--
-- Name: spaces rooms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT rooms_pkey PRIMARY KEY (short_name);


--
-- Name: wires wires_pkey1; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wires
    ADD CONSTRAINT wires_pkey1 PRIMARY KEY (uid);


--
-- Name: interfaces_uid_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX interfaces_uid_idx ON public.interfaces USING btree (uid);


--
-- Name: circuits circuits_panel_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.circuits
    ADD CONSTRAINT circuits_panel_fkey FOREIGN KEY (panel) REFERENCES public.panels(short_name);


--
-- Name: interfaces interfaces_circuit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT interfaces_circuit_fkey FOREIGN KEY (circuit) REFERENCES public.circuits(uid);


--
-- Name: interfaces interfaces_interface_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT interfaces_interface_type_fkey FOREIGN KEY (interface_type) REFERENCES public.interface_types(short_name);


--
-- Name: interfaces interfaces_room_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT interfaces_room_fkey FOREIGN KEY (space) REFERENCES public.spaces(short_name);


--
-- Name: interfaces interfaces_sits_within_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.interfaces
    ADD CONSTRAINT interfaces_sits_within_fkey FOREIGN KEY (sits_within) REFERENCES public.interfaces(uid);


--
-- Name: panels panels_circuit_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.panels
    ADD CONSTRAINT panels_circuit_fkey FOREIGN KEY (circuit) REFERENCES public.circuits(uid);


--
-- Name: spaces rooms_floor_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.spaces
    ADD CONSTRAINT rooms_floor_fkey FOREIGN KEY (floor) REFERENCES public.floors(uid);


--
-- Name: wires wires_connects_from_breaker_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wires
    ADD CONSTRAINT wires_connects_from_breaker_fkey FOREIGN KEY (connects_from_breaker) REFERENCES public.circuits(uid);


--
-- Name: wires wires_connects_from_interface_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wires
    ADD CONSTRAINT wires_connects_from_interface_fkey FOREIGN KEY (connects_from_interface) REFERENCES public.interfaces(uid);


--
-- Name: wires wires_connects_to_interface_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wires
    ADD CONSTRAINT wires_connects_to_interface_fkey FOREIGN KEY (connects_to_interface) REFERENCES public.interfaces(uid);


--
-- PostgreSQL database dump complete
--

\unrestrict jKlO1l2ZAcjfcOOFmCDjtp8Y1YYLjJGCx1xE7kJxVLnqggd5etNzFFHRCf6klbm

