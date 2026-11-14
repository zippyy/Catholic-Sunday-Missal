import Foundation

enum DevotionalContent {
    static let prayers: [(String, String)] = [
        ("Sign of the Cross", "In the name of the Father, and of the Son, and of the Holy Spirit. Amen."),
        ("Our Father", "Our Father, who art in heaven, hallowed be thy name; thy kingdom come; thy will be done on earth as it is in heaven. Give us this day our daily bread; and forgive us our trespasses, as we forgive those who trespass against us; and lead us not into temptation, but deliver us from evil. Amen."),
        ("Hail Mary", "Hail Mary, full of grace, the Lord is with thee. Blessed art thou among women, and blessed is the fruit of thy womb, Jesus. Holy Mary, Mother of God, pray for us sinners, now and at the hour of our death. Amen."),
        ("Glory Be", "Glory be to the Father, and to the Son, and to the Holy Spirit. As it was in the beginning, is now, and ever shall be, world without end. Amen."),
        ("Apostles’ Creed", "I believe in God, the Father almighty, Creator of heaven and earth, and in Jesus Christ, his only Son, our Lord, who was conceived by the Holy Spirit, born of the Virgin Mary, suffered under Pontius Pilate, was crucified, died and was buried; he descended into hell; on the third day he rose again from the dead; he ascended into heaven, and is seated at the right hand of God the Father almighty; from there he will come to judge the living and the dead. I believe in the Holy Spirit, the holy catholic Church, the communion of saints, the forgiveness of sins, the resurrection of the body, and life everlasting. Amen."),
        ("Act of Contrition", "O my God, I am heartily sorry for having offended thee, and I detest all my sins because I dread the loss of heaven and the pains of hell, but most of all because they offend thee, my God, who art all good and deserving of all my love. I firmly resolve, with the help of thy grace, to confess my sins, to do penance, and to amend my life. Amen."),
        ("Hail, Holy Queen", "Hail, Holy Queen, Mother of mercy, our life, our sweetness and our hope. To thee do we cry, poor banished children of Eve. To thee do we send up our sighs, mourning and weeping in this valley of tears. Turn then, most gracious advocate, thine eyes of mercy toward us, and after this our exile show unto us the blessed fruit of thy womb, Jesus. O clement, O loving, O sweet Virgin Mary."),
        ("Memorare", "Remember, O most gracious Virgin Mary, that never was it known that anyone who fled to thy protection, implored thy help, or sought thy intercession was left unaided. Inspired by this confidence, I fly unto thee, O Virgin of virgins, my Mother. To thee do I come; before thee I stand, sinful and sorrowful. O Mother of the Word Incarnate, despise not my petitions, but in thy mercy hear and answer me. Amen."),
        ("Prayer to St. Michael", "Saint Michael the Archangel, defend us in battle. Be our protection against the wickedness and snares of the devil. May God rebuke him, we humbly pray; and do thou, O Prince of the heavenly host, by the power of God, cast into hell Satan and all the evil spirits who prowl about the world seeking the ruin of souls. Amen."),
        ("Guardian Angel Prayer", "Angel of God, my guardian dear, to whom God’s love commits me here, ever this day be at my side, to light and guard, to rule and guide. Amen."),
        ("Grace Before Meals", "Bless us, O Lord, and these thy gifts, which we are about to receive from thy bounty, through Christ our Lord. Amen."),
        ("Grace After Meals", "We give thee thanks, almighty God, for all thy benefits, who livest and reignest for ever and ever. Amen."),
        ("Morning Offering", "O Jesus, through the Immaculate Heart of Mary, I offer you my prayers, works, joys, and sufferings of this day for all the intentions of your Sacred Heart. Amen."),
        ("Eternal Rest", "Eternal rest grant unto them, O Lord, and let perpetual light shine upon them. May they rest in peace. Amen."),
        ("Come, Holy Spirit", "Come, Holy Spirit, fill the hearts of your faithful and kindle in them the fire of your love. Send forth your Spirit and they shall be created, and you shall renew the face of the earth.")
    ]

    static let joyful = ["The Annunciation", "The Visitation", "The Nativity", "The Presentation in the Temple", "The Finding in the Temple"]
    static let luminous = ["The Baptism of Jesus in the Jordan", "The Wedding at Cana", "The Proclamation of the Kingdom of God", "The Transfiguration", "The Institution of the Eucharist"]
    static let sorrowful = ["The Agony in the Garden", "The Scourging at the Pillar", "The Crowning with Thorns", "The Carrying of the Cross", "The Crucifixion"]
    static let glorious = ["The Resurrection", "The Ascension", "The Descent of the Holy Spirit", "The Assumption of Mary", "The Coronation of Mary"]

    static let rosary: [(String, String)] = {
        var result: [(String, String)] = [
            ("How to Pray the Rosary", "1. Make the Sign of the Cross and pray the Apostles’ Creed.\n\n2. On the first large bead pray the Our Father.\n\n3. On the next three small beads pray three Hail Marys, traditionally for faith, hope, and charity.\n\n4. Pray the Glory Be.\n\n5. Announce the first mystery and pray the Our Father.\n\n6. For each decade, pray ten Hail Marys while meditating on the mystery, then the Glory Be. The Fatima Prayer may follow.\n\n7. Repeat for all five mysteries.\n\n8. Conclude with the Hail, Holy Queen and the Sign of the Cross."),
            ("Mysteries by Day", "Monday and Saturday: Joyful\n\nTuesday and Friday: Sorrowful\n\nWednesday and Sunday: Glorious\n\nThursday: Luminous\n\nSeasonal customs may vary."),
            ("Fatima Prayer", "O my Jesus, forgive us our sins, save us from the fires of hell; lead all souls to heaven, especially those in most need of thy mercy. Amen.")
        ]
        for (name, mysteries) in [("Joyful Mysteries", joyful), ("Luminous Mysteries", luminous), ("Sorrowful Mysteries", sorrowful), ("Glorious Mysteries", glorious)] {
            result.append((name, mysteries.enumerated().map { "\($0.offset + 1). \($0.element)" }.joined(separator: "\n\n")))
        }
        result.append(contentsOf: prayers.filter { ["Our Father", "Hail Mary", "Glory Be", "Apostles’ Creed", "Hail, Holy Queen"].contains($0.0) })
        return result
    }()
}
