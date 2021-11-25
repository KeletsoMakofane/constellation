const TopicRestriction = (topicChosen) => {

            switch (topicChosen) {
            case "racism":
                return "(p.racism = true)";

            case "covid":
                return "(p.covid = true)";

            case "racism_covid":
                return "(p.racism_covid = true)";

                default:
                return "(exists(p.id))";
        }
}


export default TopicRestriction;